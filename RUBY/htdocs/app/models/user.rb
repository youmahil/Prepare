# ... 중간 생력 ...
# Find uid by firstname (Append By YAONG / 2023-01-10)
def self.find_uid_by_firstname(firstname)
	#로그 기록
	logger.info("===== YAONG? find_uid_by_firstname :: INPUT = #{firstname}") if logger
	
	# Fail over to case-insensitive if none was found
	user = find_by("LOWER(firstname) = ?" , firstname)
	
	#로그 기록
	logger.info("===== YAONG? find_uid_by_firstname :: id = #{user.id}") if logger
	
	#마지막 문장의 값이 리턴되는 값, user객체의 id 값을 반환한다(사용자 테이블의 PK인 id 필드 값)
	uid = user.id
end

# Find uid by group Append By YAONG / 2023-02-27)
def self.find_uid_by_group(lastname)
	#로그 기록
	logger.info("===== YAONG? find_uid_by_group :: INPUT = #{lastname}") if logger
	
	# Fail over to case-insensitive if none was found
	user = User.find_by_sql [ "SELECT id FROM users WHERE lastname = :last_name AND type = 'Group'" , {:last_name => lastname}]
	
	#로그 기록
	logger.info("===== YAONG? find_uid_by_group :: id = #{user.at(0).id}") if logger
	
	#마지막 문장의 값이 리턴되는 값, user객체의 id 값을 반환한다(사용자 테이블의 PK인 id 필드 값)
	uid = user.at(0).id
end
# ... 중간 생력 ...
