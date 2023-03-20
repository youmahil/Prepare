#Made By BD Giant Cat(youmahil@bluedigm.com)
module MessageAgent
	module Memo
		class << self
			def initialize
			
			end
			def callmemo(callerobj)
				puts ">>>>>> Send Memo !!!"
				puts ">>>>>> callerobj = #{callerobj}"
				
				if callerobj.kind_of?(Journal)
					puts ">>>>> callerobj is Journal!!!"
					journal = callerobj
					issue = journal.journalized
					
					users = journal.notified_users | journal.notified_watchers
					users.select! do |user|
						journal.notes? || journal.visible_details(user).any?
					end
				elsif callerobj.kind_of?(Issue)
					puts ">>>>> callerobj is Issue!!!"
					issue = callerobj
					
					users = issue.notified_users | issue.notified_watchers
				end
				
				bodystr = "<br/>* 프로젝트 명칭 : #{issue.project.name} <br/>* 일감 종류 : #{issue.tracker.name}<br/>* 일감 번호 : ##{issue.id}<br/>"
				bodystr += "* 일감 상태 : #{issue.status.name}" if Settings.show_status_changes_in_mail_subject?
				bodystr += "<br/>* 일감 제목 : #{issue.subject}"
				
				puts ">>>>> bodystr = #{bodystr}"
				
				users.each do |user|
					puts ">>>>> user = #{user.id} / #{user.login} / #{user.firstname}"
					
					subjectstr = "***** 레드마인 일감 확인 요청 *****"
					msgbody = "레드마인에서 아래의 해당 일감을 확인하시기 바랍니다.<br/>#{bodystr}"
					
					puts ">>>>> subjectstr = #{subjectstr}"
					puts ">>>>> msgbody = #{msgbody}"
					
					###############################################################################
					# CUSTOMIZING_POINT ##### 업무 프로젝트 공식 개발서버에 규현한 임의의 쪽지 전송 테스트 기능의 경우(시작)
					uri = URI('https://zzloan.kbstar.com/quics')
					https = Net::HTTP.new(uri.host, uri.port)
					https.use_ssl = true
					https.verify_mode = OpenSSL::SSL::VERIFY_NONE	# SSL 검증 무시 처리
					
					req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' => 'text/html'})
					req.set_form_data({"page" => "C107374" , "QAction" => "1075338" , "RType" => "json", "userId" => user.login , "subject" => subjectstr , "messageBody" => msgbody})
					res = https.request(req)
					
					puts ">>>>> QUICS RESPONSE = #{res.code} / #{res.message} / #{res.body}"
					# CUSTOMIZING_POINT ##### 업무 프로젝트 공식 개발서버에 규현한 임의의 쪽지 전송 테스트 기능의 경우(끝)
					###############################################################################
				end
				puts ">>>>> End of Send Memo!!!"
			end
		end
	end
end
