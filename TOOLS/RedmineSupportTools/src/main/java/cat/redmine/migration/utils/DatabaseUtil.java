package cat.redmine.migration.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
* 설명 :
* 작성자 : 전길수
* 작성일 : 2022.7.14.
* 변경일 : 2022.7.14.
*/
public class DatabaseUtils{
	/**
	* 데이터베이스 Connection울 얻는다.
	*/
	
	public static Connection getConnection() throws SQLException, IllegalAccessException, InstantiationException, ClassNotFoundException {
		// CUSTOMIZING_POINT :: 레드마인 Installer에 의한 설치 과정에서, 관리 사용자의 로그인 계정 및 비밀번호 요청 시 입력한 비밀번호
		String dbPassword = "admin2redmine";
		
		Connection conn = null;
		
		try{
			Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
			conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bitnami_redmine" , "root", dbPassword);
		}catch(SQLException se){
			throw se;
		}catch(IllegalAccessException e){
			throw e;
		}catch(InstantiationException e){
			throw e;
		}catch(ClassNotFoundException e){
			throw e;
		}
		
		return conn;
	}
}
