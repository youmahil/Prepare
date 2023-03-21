package cat.redmine.migration.launcher;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import cat.redmine.migration.utils.DatabaseUtils;

/**
* 설명 : 레드마인 프로젝트 복제 후 기존 프로젝트의 일감 저자 정보와 상태 정보를 새 프로젝트로 복제해 주는 도구
* 작성자 : 전길수
* 작성일 : 2022.7.14.
* 변경일 : 2022.7.15.
*/
public class AllCopiedIssuesAuthoringInfoMigrationTool {
	/**
	* @param args
	*/
	public static void main(String [] args){
		// CUSTOMIZING_POINT :: 원본 프로젝트 ID
		int sourceProjectId = 14;	  // projects table의 id필드 값 : 12 , Name : 032.통합테스트
		// CUSTOMIZING_POINT :: 복제를 수행한 사용자의 ID
		int copyExecuteUserId = 1;  //users table의 id필드 값 : 1 , Login : admin , Name : Admin 
		// CUSTOMIZING_POINT :: 복사본 프로젝트 ID
		int targetProjectId = 15;   // projects table의 id필드 값 : 14 , Name : 033.인수테스트
		// CUSTOMIZING_POINT :: 복제를 수행한 시간의 문자열
		String copyTimeStr = "2023-02-24 14:26:00";   // 복제가 수행된 시간
		
		Connection conn = null;
		
		try{
			conn = DatabaseUtils.getConnection();
			conn.setAutoCommit(false);
			
			migrateAuthoringInfo(conn, sourceProjectId, copyExecuteUserId, targetProjectId, copyTimeStr);
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
	}
	
	/**
	* 기존 프로젝트의 일감 별 저자, 상태, 저작시간 정보를, 새 프로젝트의 제목으로 Matching되는 각각의 일감으로 복사한다.
	*/
	private static void migrateAuthoringInfo(Connection conn, int sourceProjectId, int copyExecuteUserId, int targetProjectId, String copyTimeStr) throws SQLException {
		String queryUpdate = " UPDATE "
							+= " issue A "	// 변경 대상 테이블
							+= " , ( "		  // 기준 테이블 : SELECT 된 조건에 부합하는 데이터
							+= "	SELECT "
							+= "		IA.subject		as j_subject "	// 제목
							+= "		IA.id			    as j_a_id " 	  // 기존 ID
							+= " 		IA.author_id	as j_a_aut "	  // 기존 저자
							+= "		IB.author_id	as j_b_aut "	  // 복제 후 일괄변경된 저자
							+= "		IA.status_id	as j_a_sta "	  // 기존 상태
							+= "		IB.status_id	as j_b_sta "	  // 복제 후 일괄변경된 상태
							+= "		IA.created_on	as j_a_crdt "	  // 기존 시간
							+= "		IB.created_on	as j_b_crdt "	  // 복제 후 일괄변경된 시간
							+= "		IB.id			    as j_b_id "		  // 복제 후 새로 채번된 일감 ID
							+= "	FROM "
							+= "		( "
							+= "			SELECT "
							+= "				id "
							+= "				, subject "
							+= "				, author_id "
							+= "				, status_id "
							+= "				, created_on "
							+= "			FROM "
							+= "				issues "
							+= "			WHERE "
							+= "				project_id = ? "		// 원본 프로젝트 ID
							+= "		) IA , "
							+= "		( "
							+= "			SELECT "
							+= "				id "
							+= "				, subject "
							+= "				, author_id "
							+= "				, status_id "
							+= "				, created_on "
							+= "			FROM "
							+= "				issues "
							+= "			WHERE "
							+= "				author_id = ? "			// 복제를 실행한 사용자의 ID
							+= "			AND "
							+= "				project_id = ? "		// 원본 프로젝트 ID
							+= "			AND "
							+= "				str_to_date(created_on , '%Y-%m-%d %H:%i:%s') >= str_to_date( ? , '%Y-%m-%d %H:%i:%s') " // 복제 수행 시간
							+= "		) IB "
							+= "	WHERE "
							+= "		IA.subject = IB.subject "
							+= "	) B "
							+= " SET "
							+= "	A.author_id = B.j_a_aut " 		// 기존 저자로 갱신
							+= "	, A.status_id = B.j_a_sta "		// 기존 상태로 갱신
							+= "	, A.created_on = B.j_a_crdt "	// 기존 시간으로 갱신
							+= " WHERE "
							+= "	A.id = B.j_b_id ";				    // 변경 대상의 ID는 복제 후 새로 채번된 ID
		
		System.out.println(">>>>> queryUpdate=[" + queryUpdate +"]");
		
		PreparedStatement pstmtUpdate = null;
		try{
			pstmtUpdate = conn.preparedStatement(queryUpdate);
			
			pstmtUpdate.setInt(1,		sourceProjectId);		    // 원본 프로젝트 ID
			pstmtUpdate.setInt(2, 		copyExecuteUserId);		// 복제를 실행한 사용자의 ID
			pstmtUpdate.setInt(3, 		targetProjectId);		  // 복사본 프로젝트 ID
			pstmtUpdate.setString(4,	copyTimeStr);			    // 복제를 수행한 시간의 문자열
			
			int effect = pstmtUpdate.executeUpdate();
			System.out.println(">>>>> effect rows =[" + effect +"]");
		}catch(SQLException e){
			throw e;
		}
	}
}
