logger.info("===== YAONG? ALL_IN_ONE , Issue = #{@issue.inspect} , Journals = #{@issue.journals.inspect}") if logger
#일감의 신규 등록이면
if @issue.new_record?
	#로그 기록
	logger.info("===== YAONG? ALL_IN_ONE NEW RECORD, assign_to_id = [#{assigned_to_id}]") if logger
	if !@issue.assigned_to_id_changed?
		#일감의 사용자 정의 필드 중 '채널구분'이 '스타뱅킹' 이면
		if @issue.custom_field_value(10) == '스타뱅킹'
			#일감의 사용자 정의 필드 중 '상품구분'이 '버팀목전세자금대출' 이면
			if @issue.custom_field_value(11) == '버팀목전세자금대출'
				#일감의 담당자를 '변지환'으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_firstname('변지환')
			#일감의 사용자 정의 필드 중 '상품구분'이 '주거안정월세대출' 이면
			elsif @issue.custom_field_value(11) == '주거안정월세대출'
				#일감의 담당자를 '김한기'로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_firstname('김한기')
			#일감의 사용자 정의 필드 중 '상품구분'이 '내집마련디딤돌대출' 이면
			elsif @issue.custom_field_value(11) == '내집마련디딤돌대출'
				#일감의 담당자를 '정봉현'으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_firstname('정봉현')	
			#일감의 사용자 정의 필드 중 '상품구분'이 '집단중도금대출' 이면
			elsif @issue.custom_field_value(11) == '집단중도금대출'
				#일감의 담당자를 '국정근'으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_firstname('국정근')	
			#일감의 사용자 정의 필드 중 '상품구분'이 '집단이주비대출' 이면
			elsif @issue.custom_field_value(11) == '집단이주비대출'
				#일감의 담당자를 '조성호'로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_firstname('조성호')	
			#일감의 사용자 정의 필드 중 '상품구분'이 '공통' 이면
			elsif @issue.custom_field_value(11) == '공통'
				#일감의 담당자를 '정세진'으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_firstname('정세진')					
			else
				#위의 조건들에 부합하지 않는 모든 다른 경우는 일감의 담당자를 '정세진'으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_firstname('정세진')				
			end
		#일감의 사용자 정의 필드 중 '채널구분'이 '인터넷뱅킹' 이면
		elsif @issue.custom_field_value(10) == '인터넷뱅킹'
			#일감의 사용자 정의 필드 중 '상품구분'이 '버팀목전세자금대출' 이면
			if @issue.custom_field_value(11) == '버팀목전세자금대출'
				#일감의 담당자를 '변지환'으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_firstname('변지환')
			#일감의 사용자 정의 필드 중 '상품구분'이 '주거안정월세대출' 이면
			elsif @issue.custom_field_value(11) == '주거안정월세대출'
				#일감의 담당자를 '김한기'로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_firstname('김한기')
			#일감의 사용자 정의 필드 중 '상품구분'이 '내집마련디딤돌대출' 이면
			elsif @issue.custom_field_value(11) == '내집마련디딤돌대출'
				#일감의 담당자를 '정봉현'으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_firstname('정봉현')	
			#일감의 사용자 정의 필드 중 '상품구분'이 '집단중도금대출' 이면
			elsif @issue.custom_field_value(11) == '집단중도금대출'
				#일감의 담당자를 '국정근'으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_firstname('국정근')	
			#일감의 사용자 정의 필드 중 '상품구분'이 '집단이주비대출' 이면
			elsif @issue.custom_field_value(11) == '집단이주비대출'
				#일감의 담당자를 '조성호'로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_firstname('조성호')	
			#일감의 사용자 정의 필드 중 '상품구분'이 '공통' 이면
			elsif @issue.custom_field_value(11) == '공통'
				# 일감의 담당자를 '정세진'으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_firstname('정세진')					
			else
				#위의 조건들에 부합하지 않는 모든 다른 경우는 일감의 담당자를 '정세진'으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_firstname('정세진')				
			end		
		end
	end
else # 일감의 신규 등록이 아닌 변경의 경우
	#일감의 상태코드 값이 변경되었으면
	if @issue.status_id_changed?
		logger.info("===== YAONG? ALL_IN_ONE STATUS CHANGED !!!") if logger
		if @issue.assigned_to_id_changed?
			#로그 기록
			logger.info("===== YAONG? ALL_IN_ONE ASSIGN CHANGED !!!") if logger
		end
		
		# 일감의 상태코드 값이 '조치완료'에 해당되는 값이면
		if @issue.status_id == 3 # 조치완료
			#로그 기록
			logger.info("===== YAONG? ALL_IN_ONE user_id = #{User.current.id} to LEADER !!!") if logger
			
			if @issue.assigned_to_id_changed?
				# 상태 + 담당자가 변경되었으면, 로그만 기록하고, 지정한대로 기록하게 놓아둔다. 
				logger.info("===== YAONG? ALL_IN_ONE STATUS(조치완료) and ASSIGN CHANGED !!!") if logger
			else
				# 상태만 변경되고 담당자가 변경되지 않았으면, 담당자를 규칙에 맞게 변경한다.
				logger.info("===== YAONG? ALL_IN_ONE STATUS(조치완료) CHANGED ONLY !!!") if logger
				# 현재 로그인된 사용자가 (김혜준, 염민영, 김동오, 천경화) 중의 한 사람이면
				if [User.find_uid_by_firstname('천경화') , \
					User.find_uid_by_firstname('김혜준') , \
					User.find_uid_by_firstname('염민영') , \
					User.find_uid_by_firstname('김동오') , \].include?(User.current.id)
					# 일감의 담당자를 '김성진'으로 변경한다.
					@issue.assigned_to_id = User.find_uid_by_firstname('김성진')	
				else
					# 현재 로그인된 사용자가 (김혜준, 염민영, 김동오, 천경화) 중의 한 사람이아닌 다른 사람이면
					# 일감의 담당자를 '정세진'으로 지정한다.
					@issue.assigned_to_id = User.find_uid_by_firstname('정세진')	
				end
			end
		end
		
		# 일감의 상태코드 값이 '검토완료'에 해당되는 값이면
		if @issue.status_id == 8 # 검토완료
			if @issue.assigned_to_id_changed?
				# 담당자가 변경되었으면, 로그만 기록하고, 지정한대로 기록하게 놓아둔다. 
				logger.info("===== YAONG? ALL_IN_ONE STATUS(검토완료) and ASSIGN CHANGED !!!") if logger
			else
				# 담당자가 변경되지 않았으면, 담당자를 규칙에 맞게 변경한다.
				# 일감의 담당자를 일감을 최초 등록한 저자로 변경한다.
				@issue.assigned_to_id = @issue.author_id
			end
		end
		
		# 일감의 상태코드 값이 '확인완료'에 해당되는 값이면
		if @issue.status_id == 7 # 확인완료
			logger.info("===== YAONG? ALL_IN_ONE STATUS(확인완료) : 상품구분 = #{@issue.custom_field_value(11)}") if logger
			#일감의 사용자 정의 필드 중 '상품구분'이 '버팀목전세자금대출' 이면
			if @issue.custom_field_value(11) == '버팀목전세자금대출'
				#일감의 담당자를 'Biz기금' 그룹으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_group('Biz기금')
			#일감의 사용자 정의 필드 중 '상품구분'이 '주거안정월세대출' 이면
			elsif @issue.custom_field_value(11) == '주거안정월세대출'
				#일감의 담당자를 'Biz기금' 그룹으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_group('Biz기금')
			#일감의 사용자 정의 필드 중 '상품구분'이 '내집마련디딤돌대출' 이면
			elsif @issue.custom_field_value(11) == '내집마련디딤돌대출'
				#일감의 담당자를 'Biz기금' 그룹으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_group('Biz기금')	
			#일감의 사용자 정의 필드 중 '상품구분'이 '집단중도금대출' 이면
			elsif @issue.custom_field_value(11) == '집단중도금대출'
				#일감의 담당자를 'Biz여신' 그룹으로지정한다.
				@issue.assigned_to_id = User.find_uid_by_group('Biz여신')	
			#일감의 사용자 정의 필드 중 '상품구분'이 '집단이주비대출' 이면
			elsif @issue.custom_field_value(11) == '집단이주비대출'
				#일감의 담당자를 'Biz여신' 그룹으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_group('Biz여신')							
			else
				#위의 조건들에 부합하지 않는 모든 다른 경우는 일감의 담당자를 '정세진'으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_firstname('정세진')				
			end	
		end
		
		# 일감의 상태코드 값이 '현업검토완료'에 해당되는 값이면
		if @issue.status_id == 11 # 현업검토완료
			logger.info("===== YAONG? ALL_IN_ONE STATUS(현업검토완료) : 상품구분 = #{@issue.custom_field_value(11)}") if logger
			# 일감의 담당자를 '정세진'으로 지정한다.
			@issue.assigned_to_id = User.find_uid_by_firstname('정세진')
		end
		
		# 일감의 상태코드 값이 '운영반영완료'에 해당되는 값이면
		if @issue.status_id == 12 # 운영반영완료
			logger.info("===== YAONG? ALL_IN_ONE STATUS(운영반영완료) : 상품구분 = #{@issue.custom_field_value(11)}") if logger
			#일감의 사용자 정의 필드 중 '상품구분'이 '버팀목전세자금대출' 이면
			if @issue.custom_field_value(11) == '버팀목전세자금대출'
				#일감의 담당자를 'Biz기금' 그룹으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_group('Biz기금')
			#일감의 사용자 정의 필드 중 '상품구분'이 '주거안정월세대출' 이면
			elsif @issue.custom_field_value(11) == '주거안정월세대출'
				#일감의 담당자를 'Biz기금' 그룹으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_group('Biz기금')
			#일감의 사용자 정의 필드 중 '상품구분'이 '내집마련디딤돌대출' 이면
			elsif @issue.custom_field_value(11) == '내집마련디딤돌대출'
				#일감의 담당자를 'Biz기금' 그룹으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_group('Biz기금')	
			#일감의 사용자 정의 필드 중 '상품구분'이 '집단중도금대출' 이면
			elsif @issue.custom_field_value(11) == '집단중도금대출'
				#일감의 담당자를 'Biz여신' 그룹으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_group('Biz여신')	
			#일감의 사용자 정의 필드 중 '상품구분'이 '집단이주비대출' 이면
			elsif @issue.custom_field_value(11) == '집단이주비대출'
				#일감의 담당자를 'Biz여신' 그룹으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_group('Biz여신')							
			else
				#위의 조건들에 부합하지 않는 모든 다른 경우는 일감의 담당자를 '정세진'으로 지정한다.
				@issue.assigned_to_id = User.find_uid_by_firstname('정세진')				
			end				
		end
	else #일감의 신규 등록이 아닌 상태이고, 상태코드값 변경이 아니다.
		# 로그만 기록하고 레드마인이 원래 하는 행동을 수행하도록 놓아둔다.
		logger.info("===== YAONG? ALL_IN_ONE NOT STATUS CHANGED, another FIELD Changed!!!") if logger
	end
end
