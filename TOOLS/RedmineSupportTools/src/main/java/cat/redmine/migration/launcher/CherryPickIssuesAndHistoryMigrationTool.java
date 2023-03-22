package cat.redmine.migration.launcher;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import cat.redmine.migration.domain.Issue;
import cat.redmine.migration.domain.Journals;
import cat.redmine.migration.domain.JournalDetails;
import cat.redmine.migration.utils.DatabaseUtils;

/**
* 설명 : 레드마인 프로젝트 복제 후 기존 프로젝트의 개별 일감에 대한 이력을 새 프로젝트로 복제해 주는 도구
* 작성자 : 전길수
* 작성일 : 2022.7.13.
* 변경일 : 2022.7.13.
*/
public class AllCopiedIssuesHistoryMigrationTool {
		/**
	* @param args
	*/
	public static void main(String [] args){
		// CUSTOMIZING_POINT :: 원본 프로젝트 ID
		int sourceProjectId = 14;	// projects table의 id필드 값 : 12 , Name : 032.통합테스트
		// CUSTOMIZING_POINT :: 원본 프로젝트 내의 특정 일감 ID
		int sourceIssueId = 174;
		// CUSTOMIZING_POINT :: 복사본 프로젝트 ID
		int targetProjectId = 15; // projects table의 id필드 값 : 14 , Name : 033.인수테스트		
		
		Connection conn = null;
		
		try{
			conn = DatabaseUtils.getConnection();
			conn.setAutoCommit(false);
			
			Isssue issue = getSpecialIssue(conn, sourceIssueId);
			System.out.println("-----> issue = "  + issue.toString());
			
			issue.setProjectId(targetProjectId);
			
			int targetIssueId = copyIssueIntoTargetProject(conn, issue);
			System.out.println("-----> New issue Id = "  + targetIssueId);
			
			// 복사 대상 저널 목록을 추출한다.
			List journalList = selectJournalsBySourceIssueId(conn, sourceProjectId, sourceIssueId, targetProjectId);
			
			// 복사 대상 저널을 복사하고, 새로운 프로젝트용으로 채번된 저널 ID를 사용하여, 기존 일감 ID의 저널 상세들을 복사한다.
			for(int i = 0; i < journalList.size(); i++){
				Journals journal = (Journals)journalList.get(i);
				createJournalAndCopyOldDetails(conn, journal);
			}
		}catch(SQLException | IllegalAccessException | InstantiationException | ClassNotFoundException e){
			e.printStackTrace();
			try{
				conn.rollback();
			}catch(SQLException e1){
				e1.printStackTrace();
			}
		}
		
		try{
			// TODO: 테스트 결과가 부합하는 것으로 확인되면 commit 처리를 수행하라.
			conn.rollback();
			//conn.commit();
			
			conn.close();
		}catch(SQLException e2){
				e2.printStackTrace();
		}
		
		System.out.println(">>>>> End of History Migration ... ");
	}
	
	/**
	* 저널을 복사하여 새로 채번된 저널 ID를 Key로 사용하고, 기존 저널 상세들을 복사한다.
	* @param conn
	* @param journal
	* @return
	* @throws SQLException
	*/
	private static int createJournalAndCopyOldDetails(Connection conn, Journals journal) throws SQLException{
		int newJournalId = 0;
		
		try{
			System.out.println("+++++> JOURNALS <" + journal.getJournalizedId() + ">="  + journal.toString());
			
			String queryInsert = "INSERT INTO journals "
								+ " (journalized_id, journalized_type, user_id, notes, created_on, private_notes ) "
								+ " VALUE (? , ?, ?, ?, str_to_date(? , '%Y-%m-%d %H:%i:%s'), ?) ";
								
			System.out.println(">>>>> queryInsert =[" + queryInsert + "]");
			
			PreparedStatement pstmtIns = conn.preparedStatement(queryInsert);
			pstmtIns.setInt(1, journal.getJournalizedId());
			pstmtIns.setString(2, journal.getJournalizedType());
			pstmtIns.setInt(3, journal.getUserId());
			pstmtIns.setString(4, journal.getNotes());
			pstmtIns.setString(5, journal.getCreatedOn());
			pstmtIns.setInt(6, journal.getPrivateNotes());
			
			int effect = pstmtIns.executeUpdate();
			
			if(effect > 0){
				String queryMaxId = "SELECT max(id) as id FROM journals WHERE journalized_id = ?";
				PreparedStatement pstmtSel = conn.preparedStatement(queryMaxId);
				pstmtSel.setInt(1, journal.getJournalizedId());
				ResultSet rs = pstmtSel.executeQuery();
				if(rs.next()){
					newJournalId = rs.getInt("id");
				}
			}
			
			// Fetch it's Old Journal Details
			String queryOldDetails = " SELECT "
									+ "		id "
									+ "		, journal_id "
									+ "		, property "
									+ "		, prop_key "
									+ "		, old_value "
									+ "		, value "
									+ " FROM "
									+ "		journal_detaild "
									+ " WHERE "
									+ "		journal_id = ? "
									
			PreparedStatement pstmtOldDetails =  conn.preparedStatement(queryOldDetails);
			pstmtOldDetails.setInt(1, journal.getOldJournalId());
			ResultSet rsOldDetails = pstmtOldDetails.executeQuery();
			
			int idx = 0;
			while(rsOldDetails.next()){
				JournalDetails details = new JournalDetails();
				
				details.setJournalId(newJournalId);
				details.setProperty(rsOldDetails.getString("property"));
				details.setPropKey(rsOldDetails.getString("prop_key"));
				details.setOldValue(rsOldDetails.getString("old_value"));
				details.setValue(rsOldDetails.getString("value"));
				
				System.out.println("=====> DETAILS >" + idx + ">=" + details.toString());
				
				String queryInsDetail = " INSERT INTO journal_details "
										+ " (journal_id, property, prop_key, old_value, value) "
										+ " VALUES (? , ? , ? , ? , ?)";
				
				System.out.println("#####> queryInsDetail=[" + queryInsDetail +"]");
				
				PreparedStatement pstmtInsDetail = conn.preparedStatement(queryInsDetail);
				pstmtInsDetail.setInt(1, details.getJournalId());
				pstmtInsDetail.setString(2, details.getProperty());
				pstmtInsDetail.setString(3, details.getPropKey());
				pstmtInsDetail.setString(4, details.getOldValue());
				pstmtInsDetail.setString(5, details.getValue());
				
				int effectDetail = pstmtInsDetail.executeUpdate();
				if(effectDetail > 0){
					System.out.println("***** Migrated 1 Journal and Details\n" + journal.toString() + "\n" + details.toString());
				}
			}
		}catch(SQLException e){
			throw e;
		}	
			
		return newJournalId;
	}
	
	/**
	* 기존 저널 목록 추출
	* @return
	* @throws SQLException
	*/
	private static List selectJournalsBySourceIssueId(Connection conn, int sourceProjectId, int sourceIssueId, int targetProjectId)  throws SQLException{
		List result = null;
		
		try{
			String query  = " SELECT DISTINCT "
							+ "		B.id 					as old_journal_id "		// 저널 PK이면서, 저널 Detail 갸별 항목의 journal_id
							+ "		, A.j_b_id				as journalized_id "
							+ "		, A.j_a_id				as old_journalized_id "
							+ "		, B.journalized_type	as journalized_type "
							+ "		, B.user_id				as user_id "
							+ "		, B.notes				as notes "
							+ "		, B.created_on			as created_on "
							+ "		, B.private_notes		as private_notes "
							+ " FROM "
							+ "		( "
							+ "			SELECT DISTINCT "
							+ "				IA.subject			as subject "			// 제목
							+ "				, IA.id				as j_a_id "				// 기존 ID
							+ "				, IA.author_id		as j_a_aut "			// 기존 저자
							+ " 			, IB.author_id		as j_b_aut "			// 복제 후 일괄변경된 저자
							+ "				, IB.id				as j_b_id "				// 복제 후 새로 채번된 일감 ID
							+ "				, IA.journals_id	as j_a_journals_id "	// 기존 저널 ID
							+ "			FROM "
							+ "				( "
							+ "					SELECT "
							+ "						IIA.id "
							+ "						, IIA.subject "
							+ "						, IIA.author_id "
							+ "						, IIB.id	as journals_id "
							+ "					FROM "
							+ "						issue IIA "
							+ "						, journals IIB "
							+ "					WHERE "
							+ "						IIA.project_id = ? "	// 원본 프로젝트 ID
							+ "					AND "
							+ "						IIA.id = ? "			// 원본 Issue ID
							+ "					AND "
							+ "						IIA.id = IIB.journalized_id "
							+ "				) IA, "
							+ "				( "
							+ "					SELECT "
							+ "						id "
							+ "						, subject "
							+ "						, author_id "
							+ "					FROM "
							+ "						issue "
							+ "					WHERE "
							+ "						project_id = ? "		// 복사본 프로젝트 ID
							+ "				) IB "
							+ "			WHERE "
							+ "				IA.subject = IB.subject "
							+ " 	) A "
							+ " 	, journal B "
							+ "	WHERE "
							+ "	A.j_a_id = B.journalized_id ";
							
			System.out.println("#####> selectJournals::query = [" + query + "]");
			
			PreparedStatement pstmt = conn.preparedStatement(query);
			pstmt.setInt(1 , sourceProjectId);
			pstmt.setInt(2 , sourceIssueId);
			pstmt.setInt(3 , targetProjectId);
			ResultSet rs = pstmt.executeQuery();
			
			int idx = 0;
			result = new ArrayList();
			while(rs.next()){
				Journals journals = new Journals();
				
				journals.setOldJournalId(rs.getInt("old_journal_id"));
				journals.setJournalizedId(rs.getInt("journalized_id"));
				journals.setOldJournalizedId(rs.getInt("old_journalized_id"));
				journals.setJournalizedType(rs.getString("journalized_type"));
				journals.setUserId(rs.getString("user_id"));
				journals.setNotes(rs.getString("notes"));
				journals.setCreatedOn(rs.getString("created_on"));
				journals.setPrivateNotes(rs.getInt("private_notes"));
				
				result.add(journals);
				
				System.out.println("----- journals<" + idx + ">=" + journals.toString());
				idx++;
			}
		}catch(SQLException e){
			throw e;
		}	
						
		return result;
	}
	
	private static Issue getSpecialIssue(Connection conn, int issueId)  throws SQLException{
		Issue result = null;
		try{
			String query = " SELECT * FROM issues WHERE id = ? ";
			System.out.println("----- query =[" + query + "]");
			
			PreparedStatement pstmt = conn.preparedStatement(query);
			pstmt.setInt(1 , issueId);
			
			ResultSet rs = pstmt.executeQuery();
			
			if(rs.next()){
				result = new Issue();
				
				result.setId(rs.getInt("id"));
				result.setTrackerId(rs.getInt("tracker_id"));
				result.setProjectId(rs.getInt("project_id"));
				result.setSubject(rs.getString("subject"));
				result.setDescription(rs.getString("description"));
				result.setDueDate(rs.getString("due_date"));
				result.setCategoryId(rs.getInt("category_id"));
				result.setStatusId(rs.getInt("status_id"));
				result.setAssignedToId(rs.getInt("assigned_to_id"));
				result.setPriorityId(rs.getInt("priority_id"));
				result.setFixedVersionId(rs.getInt("fixed_version_id"));
				result.setAuthorId(rs.getInt("author_id"));
				result.setLockVersion(rs.getInt("lock_version"));
				result.setCreatedOn(rs.getString("created_on"));
				result.setUpdatedOn(rs.getString("updated_on"));
				result.setStartDate(rs.getString("start_date"));
				result.setDoneRatio(rs.getInt("done_ratio"));
				result.setEstimatedHours(rs.getFloat("estimated_hours"));
				result.setParentId(rs.getInt("parent_id"));
				result.setRootId(rs.getInt("root_id"));
				result.setLft(rs.getInt("lft"));
				result.setRgt(rs.getInt("rgt"));
				result.setPrivate(rs.getString("is_private"));
				result.setClosedOn(rs.getString("closed_on"));
			}
			
		}catch(SQLException e){
			throw e;
		}	
						
		return result;		
	}
	
	private static int copyIssueIntoTargetProject(Connection conn, Issue issue)  throws SQLException{
		int newIssueId = 0;
		System.out.println("----- copyIssueIntoTargetProject::issue=" + issue.getString();
		
		try{
			String queryInsert = "";
		}catch(SQLException e){
			throw e;
		}	
						
		return newIssueId;	
	}
}
