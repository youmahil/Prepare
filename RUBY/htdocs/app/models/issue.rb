#... 중간 생략 ...
def send_notification
   if notify? && Setting.notified_events.include?('issue_added')
     
     ##### GIANTCAT_APPENDED(S)
     puts "@@@@@ send_notification --- calling message agent!!!"
     memo = MessageAgent::Memo.callmemo(self)
     puts "@@@@@ send_notification --- called message agent!!!"
     ##### GIANTCAT_APPENDED(E)
     
     Mailer.deliver_issue_add(self)
   end
end
#... 중간 생략 ...
