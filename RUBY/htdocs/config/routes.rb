#... 중간 생략 ...
Rails.application.routes.draw do
  #root :to => 'welcome#index' , :as => 'home'
  #위 문장을 아래와 같이 변경한다(첫 페이지를 내 페이지로 설정)
  root :to => 'my#page' , :vis => :get , :as => 'home'
  #... 중간 생략 ...
end
#... 중간 생략 ...
