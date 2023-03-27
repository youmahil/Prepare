class ProcStatusViewerController < ApplicationController
	before_action :require_admin, :except => :index
	before_action :require_admin_or_api_request, :only => :index
	accept_api_auth :index
	
	def index
		type = params[:type]
		puts "*** type = #{type}"
		
		if type == 'p1'
			puts "*** type is p1 / 분석설계 / argprjval = 4"
			#CUSTOMIZING_POINT ### 분석설계 프로젝트 ID
			argprjval = 4
			#CUSTOMIZING_POINT ### '테스트환경'에 해당되는 사용자 정의 필드 ID
			testenv = 0
			channel_div_id = 10
			product_div_id = 11
		elsif type == 'd1'
			puts "*** type is d1 / 개발수행 / argprjval = 10"
			#CUSTOMIZING_POINT ### 개발수행 프로젝트 ID
			argprjval = 10
			#CUSTOMIZING_POINT ### '테스트환경'에 해당되는 사용자 정의 필드 ID
			testenv = 0		
		elsif type == 't1'
			puts "*** type is t1 / 단위테스트 / argprjval = 7"
			#CUSTOMIZING_POINT ### 단위테스트 프로젝트 ID
			argprjval = 7
			#CUSTOMIZING_POINT ### '테스트환경'에 해당되는 사용자 정의 필드 ID
			testenv = 9			
		elsif type == 't2'
			puts "*** type is t2 / 통합테스트 / argprjval = 12"
			#CUSTOMIZING_POINT ### 통합테스트 프로젝트 ID
			argprjval = 12
			#CUSTOMIZING_POINT ### '테스트환경'에 해당되는 사용자 정의 필드 ID
			testenv = 9			
		elsif type == 't3'
			puts "*** type is t3 / 인수테스트 / argprjval = 14"
			#CUSTOMIZING_POINT ### 인수테스트 프로젝트 ID
			argprjval = 14
			#CUSTOMIZING_POINT ### '테스트환경'에 해당되는 사용자 정의 필드 ID
			testenv = 9			
		elsif type == 't4'
			puts "*** type is t4 / 인수테스트 / argprjval = 15"
			#CUSTOMIZING_POINT ### 인수테스트 프로젝트 ID
			argprjval = 15
			#CUSTOMIZING_POINT ### '테스트환경'에 해당되는 사용자 정의 필드 ID
			testenv = 9				
		end
		
		#CUSTOMIZING_POINT ### '조치완료'에 해당되는 일감 상태 필드 ID
		fixedstatus = 3
		#CUSTOMIZING_POINT ### '업무구분'에 해당되는 사용자 정의 필드 ID
		businesskind = 13	
		#CUSTOMIZING_POINT ### '채널구분'에 해당되는 사용자 정의 필드 ID
		channel_div_id = 10
		#CUSTOMIZING_POINT ### '상품구분'에 해당되는 사용자 정의 필드 ID
		product_div_id = 11
		
		puts "argprjval = #{argprjval}"
		query = <<-SQL
			SELECT
				A.id																									as '#'
				, (SELECT name FROM projects WHERE id = A.project_id)													as 프로젝트
				, (SELECT value FROM custom_values WHERE custom_field_id = #{businesskind} AND customized_id = A.id)	as 업무구분
				, (SELECT name FROM trackers WHERE id = A.tracker_id)													as 유형
				, (SELECT value FROM custom_values WHERE custom_field_id = #{testenv} AND customized_id = A.id)			as 테스트환경
				, (SELECT value FROM custom_values WHERE custom_field_id = #{channel_div_id} AND customized_id = A.id)	as 채널구분
				, (SELECT value FROM custom_values WHERE custom_field_id = #{product_div_id} AND customized_id = A.id)	as 상품구분
				, A.subject			as 제목
				, A.description		as 일감설명
				-- , A.status_id	as 현재상태ID
				, (
					CASE
						WHEN A.status_id = 1 then '신규'			      -- CUSTOMIZING_POINT
						WHEN A.status_id = 2 then '조치중'			     -- CUSTOMIZING_POINT
						WHEN A.status_id = 3 then '조치완료'		    -- CUSTOMIZING_POINT
						WHEN A.status_id = 7 then '확인완료'		    -- CUSTOMIZING_POINT
						WHEN A.status_id = 8 then '검토완료'		    -- CUSTOMIZING_POINT
						WHEN A.status_id = 9 then '재결함'			     -- CUSTOMIZING_POINT
						WHEN A.status_id = 10 then '운영CM제외'	    -- CUSTOMIZING_POINT
						WHEN A.status_id = 11 then '현업검토완료'	  -- CUSTOMIZING_POINT
						WHEN A.status_id = 12 then '운영반영완료'	  -- CUSTOMIZING_POINT
						WHEN A.status_id = 13 then '운영확인완료'	  -- CUSTOMIZING_POINT
						ELSE '알수없음'							                -- CUSTOMIZING_POINT
					END
					)	as 상태
				, (SELECT name FROM enumerations WHERE id = A.priority_id)	as 우선순위
				-- , A.author_id as 일감저자ID
				, IF (
						(SELECT firstname FROM users WHERE id = A.author_id) = ''
						, '이름없음'
						, (SELECT firstname FROM users WHERE id = A.author_id)
					)	as 저자
				, IF (
						(SELECT firstname FROM users WHERE id = A.assign_to_id) = ''
						, (SELECT lastname FROM users WHERE id = A.assign_to_id)
						, (SELECT firstname FROM users WHERE id = A.assign_to_id)
					)	as 담당자
				, date_format(A.created_on , '%Y-%m-%d %H:%i:%s')	as 등록
				, date_format(A.updated_on , '%Y-%m-%d %H:%i:%s')	as 완료일
				, date_format(A.due_date , '%Y-%m-%d %H:%i:%s')		as 완료기한
				, CASE
					WHEN A.status_id = 7 then '기한 내/외 검사 안함(확인완료 상태)'
					ELSE
					(
						SELECT concat(concat('기한', abs(datediff(date_format(now(), '%Y-Ym-%d'), date_format(A.due_date, '%Y-%m-%d')))), '일 ')
									, IF(datediff(date_format(now(), '%Y-%m-%d'), date_format(A.due_date, '%Y-%m-%d')) < 0 , '남음' , '초과')
								)
					)
				END		as 기한문자열
				, (
					SELECT
						(SELECT firstname FROM users WHERE id = B.user_id)	as fixusername
					FROM
						journals B
						, journal_details C
					WHERE
						B.id = C.journal_id
					AND
						C.prop_key = 'status_id'
					AND
						C.value = #{fixedstatus}	-- 조치완료
					AND
						A.id = B.journalized_id
					ORDER BY C.journal_id DESC LIMIT 1	-- 조치완료가 여러 번 존재할 때 마지막 조치 건 추출
					)	as 조치자이름
				, (
					SELECT
						date_format(B.created_on, '%Y-%m-%d %H:%i:%s')
					FROM
						journals B
						, journal_details C
					WHERE
						B.id = C.journal_id
					AND
						C.prop_key = 'status_id'
					AND
						C.value = #{fixedstatus}	-- 조치완료
					AND
						A.id = B.journalized_id
					ORDER BY C.journal_id DESC LIMIT 1	-- 조치완료가 여러 번 존재할 때 마지막 조치 건 추출
					)	as 조치기록일시
			FROM
				issues A
			WHERE
				A.project_id = #{argprjval}	-- 프로젝트의 ID
			ORDER BY A.id DESC
		SQL
		
		puts "QUERY = #{query}"
		
		if ["p1", "d1"].include?(type)
			puts "~~~~~ TYPE include p1 or d1..."
		else
			puts "~~~~~ TYPE does NOT include p1 or d1..."
		end 
		
		puts "QUERY USING >>> ActiveRecord::Base.connection.execute!!!"
		
		@results = ActiveRecord::Base.connection.execute(query)
		
		puts "Result Count = #{@results.count}"
		
		puts "Result Class = #{@results.class}"
		
		puts "*** Result Rows ***"	
		@results.each do |row|
			#puts "#{row[0]} ... "
			if ["p1", "d1"].include?(type)
				inquery = <<-INSQL
					SELECT
						change_date
						, user_id
						, IF(notes = 'EMPTY_VALUE' , '' , notes) as notes
						, prop_key
						, old_value
						, value
						, translated
					FROM
						(
							SELECT
								UT.keyValue
								, UT.change_date
								, UT.user_id
								, UT.notes
								, UT.histcount
								, UT.prop_key
								, UT.old_value
								, UT.value
								, IF( (UT.histcount = 0 and notes not null and prop_key  is null)
									, concat('사용자【' , (SELECT firstname FROM users WHERE id = user_id) , '】이(가) 속성 변경 없이 노트 정보만 기록함.')
									, IF( UT.histcount > 0
										, concat('사용자【' ,(SELECT firstname FROM users WHERE id = user_id) , '】이(가) 노트 정보만 기록함.')
										, IF(UT.prop_key is null
											, ''
											, concat
											(
												'사용자【'
												, (SELECT firstname FROM users WHERE id = user_id)
												, CASE
													WHEN property = 'attachment' THEN '】에 의해'
													ELSE '】이(가)【' 
												END 
												, (
													CASE
														WHEN prop_key = 'tracker_id'		  THEN '유형'
														WHEN prop_key = 'status_id'			  THEN '상태'
														WHEN prop_key = 'assign_to_id'		THEN '담당자'
														-- WHEN prop_key = '#{testenv}'		THEN '테스트환경'
														WHEN prop_key = 'subject'			    THEN '제목'
														WHEN prop_key = 'done_ratio'		  THEN '진척도'
														WHEN prop_key = 'estimated_hours'	THEN '추정시간'
														WHEN prop_key = 'due_date'			  THEN '완료기한'
														WHEN prop_key = 'priority_id'		  THEN '우선순위'
														WHEN prop_key = 'description'		  THEN '설명'
														WHEN prop_key = 'start_date'		  THEN '시작시간'
														ELSE
															CASE
																WHEN property = 'attachment' THEN ''
																WHEN property = 'cf' THEN (SELECT name FROM custom_fields WHERE id = prop_key)
																ELSE '알수없음'
															END 
													END 
												)
												, CASE
													WHEN property = 'attachment' THEN   CASE
																							WHEN old_value = 'f' THEN ''
																							ELSE '에【'
																						END
													ELSE '】을(를)【' 
												END 
												, (
													CASE
														WHEN prop_key = 'tracker_id'	THEN (SELECT name FROM trackers WHERE id = old_value)
														WHEN prop_key = 'status_id'		THEN 
														(
															CASE
																WHEN old_value = 1 	then '신규'		        -- CUSTOMIZING_POINT
																WHEN old_value = 2 	then '조치중'		     -- CUSTOMIZING_POINT
																WHEN old_value = 3 	then '조치완료'	      -- CUSTOMIZING_POINT
																-- WHEN old_value = 5 	then '확인완료'	  -- CUSTOMIZING_POINT
																WHEN old_value = 7 	then '확인완료'	      -- CUSTOMIZING_POINT
																WHEN old_value = 8 	then '검토완료'	      -- CUSTOMIZING_POINT
																WHEN old_value = 9 	then '재결함'		     -- CUSTOMIZING_POINT
																WHEN old_value = 10 then '운영CM제외'	    -- CUSTOMIZING_POINT
																WHEN old_value = 11 then '현업검토완료'	  -- CUSTOMIZING_POINT
																WHEN old_value = 12 then '운영반영완료'	  -- CUSTOMIZING_POINT
																WHEN old_value = 13 then '운영확인완료'	  -- CUSTOMIZING_POINT
																ELSE '알수없음'						                -- CUSTOMIZING_POINT
															END 
														)
														WHEN prop_key = 'assign_to_id'		THEN IF(IFNULL((SELECT firstname FROM users WHERE id = old_value) , '담당자 없음') = '' , (SELECT lastname FROM users WHERE id = old_value) , IFNULL((SELECT firstname FROM users WHERE id = old_value) , '담당자 없음') )
														-- WHEN prop_key = '#{testenv}'		THEN old_value
														WHEN prop_key = 'subject'			THEN old_value
														WHEN prop_key = 'done_ratio'		THEN old_value
														WHEN prop_key = 'estimated_hours'	THEN IF(old_value is null, '없음' , concat(old_value , 'h'))
														WHEN prop_key = 'due_date'			THEN IF(old_value is null, '없음' , old_value)
														WHEN prop_key = 'priority_id'		THEN (SELECT name FROM enumerations WHERE id = old_value)
														WHEN prop_key = 'description'		THEN IF(old_value is null, '없음' , old_value)
														WHEN prop_key = 'start_date'		THEN IF(old_value is null, '없음' , old_value)
														ELSE
															CASE
																WHEN property = 'attachment' THEN IF(old_value is null, '없음' , IF(old_value = 'f' , '' , old_value))
																WHEN property = 'cf' THEN IF(old_value is null, '없음' , old_value)
																ELSE '알수없음'
															END 
													END 
												)
												, CASE
													WHEN property = 'attachment' THEN   CASE
																							WHEN old_value = 'f' THEN ''
																							ELSE '】에서【' 
																						END 
													ELSE '】에서【' 
												END 
												, (
													CASE
														WHEN prop_key = 'tracker_id'	THEN (SELECT name FROM trackers WHERE id = value)
														WHEN prop_key = 'status_id'		THEN 
														(
															CASE
																WHEN value = 1 	then '신규'		        -- CUSTOMIZING_POINT
																WHEN value = 2 	then '조치중'		     -- CUSTOMIZING_POINT
																WHEN value = 3 	then '조치완료'	      -- CUSTOMIZING_POINT
																WHEN value = 7 	then '확인완료'	      -- CUSTOMIZING_POINT
																WHEN value = 8 	then '검토완료'	      -- CUSTOMIZING_POINT
																WHEN value = 9 	then '재결함'		     -- CUSTOMIZING_POINT
																WHEN value = 10 then '운영CM제외'	    -- CUSTOMIZING_POINT
																WHEN value = 11 then '현업검토완료'	  -- CUSTOMIZING_POINT
																WHEN value = 12 then '운영반영완료'	  -- CUSTOMIZING_POINT
																WHEN value = 13 then '운영확인완료'	  -- CUSTOMIZING_POINT
																ELSE '알수없음'					-- CUSTOMIZING_POINT
															END
														)
														WHEN prop_key = 'assign_to_id'		THEN IF(IFNULL((SELECT firstname FROM users WHERE id = value) , '담당자 없음') = '' , (SELECT lastname FROM users WHERE id = value) , IFNULL((SELECT firstname FROM users WHERE id = value) , '담당자 없음') )
														-- WHEN prop_key = '#{testenv}'		THEN value
														WHEN prop_key = 'subject'			THEN value
														WHEN prop_key = 'done_ratio'		THEN value
														WHEN prop_key = 'estimated_hours'	THEN IF(value is null, '없음' , concat(value , 'h'))
														WHEN prop_key = 'due_date'			THEN IF(value is null, '없음' , value)
														WHEN prop_key = 'priority_id'		THEN (SELECT name FROM enumerations WHERE id = value)
														WHEN prop_key = 'description'		THEN IF(value is null, '없음' , value)
														WHEN prop_key = 'start_date'		THEN IF(value is null, '없음' , value)
														ELSE CASE
																WHEN property = 'attachment' THEN   CASE
																										WHEN value is null THEN ''
																										ELSE value
																									END 
																WHEN property = 'cf' THEN IF(value is null, '없음' , value)
																ELSE '알수없음' 
															 END 
													END
												)
												, CASE
													WHEN property = 'attachment' THEN   CASE
																							WHEN value is null THEN '값이 지워짐.】(으)로 변경 처리함.'
																							ELSE '】(이)가 추가됨.'
																						END 
													ELSE '】(으)로 변경 처리함.'
												END 
											)
										) -- inner IF
									) -- middle IF
								)	as translated	-- outer IF 
							FROM
								(
									SELECT
										id												  as keyValue
										, date_format(created_on , '%Y-%m-%d %H:%i:%s')	as change_date
										, user_id										as user_id
										, notes											as notes
										, (
											SELECT	
												count(journal_id)
											FROM
												journal_details
											WHERE
												journal_id = JA.id 
										)												    as histcount
										, null											as property
										, null											as prop_key
										, null											as old_value
										, null											as value
									FROM 
										journals JA
									WHERE
										journalized_id = #{row[0]}
									UNION
									SELECT
										JB.journal_id										as keyValue
										, date_format(JA.created_on , '%Y-%m-%d %H:%i:%s')	as change_date
										, JA.user_id										as user_id
										, 'EMPTY_VALUE'									as notes
										, 0													    as histcount
										, JB.property										as property
										, JB.prop_key										as prop_key
										, JB.old_value									as old_value
										, JB.value											as value
									FROM
										issues issues
										, journals JA LEFT OUTER JOIN journal_details JB
											ON JA.id = JB.journal_id
									WHERE
										ISS.id = #{row[0]}
									AND
										ISS.id = JB.journal_id
									ORDER BY keyValue ASC
								) UT
							WHERE
								UT.keyValue is not null
						)UTO
					WHERE
						length (UTO.notes) <> 0
				INSQL				
			else 
				inquery = <<-INSQL
					SELECT
						change_date
						, user_id
						, IF(notes = 'EMPTY_VALUE' , '' , notes) as notes
						, prop_key
						, old_value
						, value
						, translated
					FROM
						(
							SELECT
								UT.keyValue
								, UT.change_date
								, UT.user_id
								, UT.notes
								, UT.histcount
								, UT.prop_key
								, UT.old_value
								, UT.value
								, IF( (UT.histcount = 0 and notes not null and prop_key  is null)
									, concat('사용자【' , (SELECT firstname FROM users WHERE id = user_id) , '】이(가) 속성 변경 없이 노트 정보만 기록함.')
									, IF( UT.histcount > 0
										, concat('사용자【' ,(SELECT firstname FROM users WHERE id = user_id) , '】이(가) 노트 정보만 기록함.')
										, IF(UT.prop_key is null
											, ''
											, concat
											(
												'사용자【'
												, (SELECT firstname FROM users WHERE id = user_id)
												, CASE
													WHEN property = 'attachment' THEN '】에 의해'
													ELSE '】이(가)【' 
												END 
												, (
													CASE
														WHEN prop_key = 'tracker_id'		THEN '유형'
														WHEN prop_key = 'status_id'			THEN '상태'
														WHEN prop_key = 'assign_to_id'		THEN '담당자'
														WHEN prop_key = '#{testenv}'		THEN '테스트환경'
														WHEN prop_key = 'subject'			THEN '제목'
														WHEN prop_key = 'done_ratio'		THEN '진척도'
														WHEN prop_key = 'estimated_hours'	THEN '추정시간'
														WHEN prop_key = 'due_date'			THEN '완료기한'
														WHEN prop_key = 'priority_id'		THEN '우선순위'
														WHEN prop_key = 'description'		THEN '설명'
														WHEN prop_key = 'start_date'		THEN '시작시간'
														ELSE
															CASE
																WHEN property = 'attachment' THEN ''
																WHEN property = 'cf' THEN (SELECT name FROM custom_fields WHERE id = prop_key)
																ELSE '알수없음'
															END 
													END 
												)
												, CASE
													WHEN property = 'attachment' THEN   CASE
																							WHEN old_value = 'f' THEN ''
																							ELSE '에【'
																						END
													ELSE '】을(를)【' 
												END 
												, (
													CASE
														WHEN prop_key = 'tracker_id'	THEN (SELECT name FROM trackers WHERE id = old_value)
														WHEN prop_key = 'status_id'		THEN 
														(
															CASE
																WHEN old_value = 1 	then '신규'		        -- CUSTOMIZING_POINT
																WHEN old_value = 2 	then '조치중'		     -- CUSTOMIZING_POINT
																WHEN old_value = 3 	then '조치완료'	      -- CUSTOMIZING_POINT
																WHEN old_value = 7 	then '확인완료'	      -- CUSTOMIZING_POINT
																WHEN old_value = 8 	then '검토완료'	      -- CUSTOMIZING_POINT
																WHEN old_value = 9 	then '재결함'		     -- CUSTOMIZING_POINT
																WHEN old_value = 10 then '운영CM제외'	    -- CUSTOMIZING_POINT
																WHEN old_value = 11 then '현업검토완료'	  -- CUSTOMIZING_POINT
																WHEN old_value = 12 then '운영반영완료'	  -- CUSTOMIZING_POINT
																WHEN old_value = 13 then '운영확인완료'	  -- CUSTOMIZING_POINT
																ELSE '알수없음'						-- CUSTOMIZING_POINT
															END 
														)
														WHEN prop_key = 'assign_to_id'		THEN IF(IFNULL((SELECT firstname FROM users WHERE id = old_value) , '담당자 없음') = '' , (SELECT lastname FROM users WHERE id = old_value) , IFNULL((SELECT firstname FROM users WHERE id = old_value) , '담당자 없음') )
														WHEN prop_key = '#{testenv}'		THEN old_value
														WHEN prop_key = 'subject'			THEN old_value
														WHEN prop_key = 'done_ratio'		THEN old_value
														WHEN prop_key = 'estimated_hours'	THEN IF(old_value is null, '없음' , concat(old_value , 'h'))
														WHEN prop_key = 'due_date'			THEN IF(old_value is null, '없음' , old_value)
														WHEN prop_key = 'priority_id'		THEN (SELECT name FROM enumerations WHERE id = old_value)
														WHEN prop_key = 'description'		THEN IF(old_value is null, '없음' , old_value)
														WHEN prop_key = 'start_date'		THEN IF(old_value is null, '없음' , old_value)
														ELSE
															CASE
																WHEN property = 'attachment' THEN IF(old_value is null, '없음' , IF(old_value = 'f' , '' , old_value))
																WHEN property = 'cf' THEN IF(old_value is null, '없음' , old_value)
																ELSE '알수없음'
															END 
													END 
												)
												, CASE
													WHEN property = 'attachment' THEN   CASE
																							WHEN old_value = 'f' THEN ''
																							ELSE '】에서【' 
																						END 
													ELSE '】에서【' 
												END 
												, (
													CASE
														WHEN prop_key = 'tracker_id'	THEN (SELECT name FROM trackers WHERE id = value)
														WHEN prop_key = 'status_id'		THEN 
														(
															CASE
																WHEN value = 1 	then '신규'		        -- CUSTOMIZING_POINT
																WHEN value = 2 	then '조치중'		     -- CUSTOMIZING_POINT
																WHEN value = 3 	then '조치완료'	      -- CUSTOMIZING_POINT
																WHEN value = 7 	then '확인완료'	      -- CUSTOMIZING_POINT
																WHEN value = 8 	then '검토완료'	      -- CUSTOMIZING_POINT
																WHEN value = 9 	then '재결함'		     -- CUSTOMIZING_POINT
																WHEN value = 10 then '운영CM제외'	    -- CUSTOMIZING_POINT
																WHEN value = 11 then '현업검토완료'	  -- CUSTOMIZING_POINT
																WHEN value = 12 then '운영반영완료'	  -- CUSTOMIZING_POINT
																WHEN value = 13 then '운영확인완료'	  -- CUSTOMIZING_POINT
																ELSE '알수없음'					-- CUSTOMIZING_POINT
															END 
														)
														WHEN prop_key = 'assign_to_id'		THEN IF(IFNULL((SELECT firstname FROM users WHERE id = value) , '담당자 없음') = '' , (SELECT lastname FROM users WHERE id = value) , IFNULL((SELECT firstname FROM users WHERE id = value) , '담당자 없음') )
														WHEN prop_key = '#{testenv}'		THEN value
														WHEN prop_key = 'subject'			  THEN value
														WHEN prop_key = 'done_ratio'		THEN value
														WHEN prop_key = 'estimated_hours'	THEN IF(value is null, '없음' , concat(value , 'h'))
														WHEN prop_key = 'due_date'			THEN IF(value is null, '없음' , value)
														WHEN prop_key = 'priority_id'		THEN (SELECT name FROM enumerations WHERE id = value)
														WHEN prop_key = 'description'		THEN IF(value is null, '없음' , value)
														WHEN prop_key = 'start_date'		THEN IF(value is null, '없음' , value)
														ELSE CASE
																WHEN property = 'attachment' THEN   CASE
																										WHEN value is null THEN ''
																										ELSE value
																									END 
																WHEN property = 'cf' THEN IF(value is null, '없음' , value)
																ELSE '알수없음' 
															 END 
													END
												)
												, CASE
													WHEN property = 'attachment' THEN   CASE
																							WHEN value is null THEN '값이 지워짐.】(으)로 변경 처리함.'
																							ELSE '】(이)가 추가됨.'
																						END 
													ELSE '】(으)로 변경 처리함.'
												END 
											)
										) -- inner IF
									) -- middle IF
								)	as translated	-- outer IF 
							FROM
								(
									SELECT
										id												as keyValue
										, date_format(created_on , '%Y-%m-%d %H:%i:%s')	as change_date
										, user_id										as user_id
										, notes											as notes
										, (
											SELECT	
												count(journal_id)
											FROM
												journal_details
											WHERE
												journal_id = JA.id 
										)												    as histcount
										, null											as property
										, null											as prop_key
										, null											as old_value
										, null											as value
									FROM 
										journals JA
									WHERE
										journalized_id = #{row[0]}
									UNION
									SELECT
										JB.journal_id										as keyValue
										, date_format(JA.created_on , '%Y-%m-%d %H:%i:%s')	as change_date
										, JA.user_id										as user_id
										, 'EMPTY_VALUE'									as notes
										, 0													    as histcount
										, JB.property										as property
										, JB.prop_key										as prop_key
										, JB.old_value									as old_value
										, JB.value											as value
									FROM
										issues issues
										, journals JA LEFT OUTER JOIN journal_details JB
											ON JA.id = JB.journal_id
									WHERE
										ISS.id = #{row[0]}
									AND
										ISS.id = JB.journal_id
									ORDER BY keyValue ASC
								) UT
							WHERE
								UT.keyValue is not null
						)UTO
					WHERE
						length (UTO.notes) <> 0
				INSQL
				
			end
			puts "INQUERY = #{inquery}"
			
			puts "INQUERY USING >>> ActiveRecord::Base.connection.execute!!!"
			@inresults = ActiveRecord::Base.connection.execute(inquery)

			inarr = []
			
			@inresults.each do |inrow|
				puts "\n <=========> #{inrow[0]} , #{inrow[1]} , #{inrow[2]} , #{inrow[3]} , #{inrow[4]} , #{inrow[5]} , #{inrow[6]}"
				inhash = {"change_date" => inrow[0] , "change_user" => inrow[1] , "note" => inrow[2] , "change_item" => inrow[3] , "change_before" => inrow[4] , "change_after" => inrow[5] , "translated" => inrow[6]}
				inarr << inhash
			end
			
			row = row.push(inarr)
			
			puts "*******************"
			puts "FINAL ROW = #{row}"
			puts "*******************"
		end
		
		respond_to do  |format|
			format.html do
				render :layout => false if request.xhr?
			end
			format.api do
				format.api
			end
		end
	end
	
end
