# Plugin's routes
get 'proc_status_viewer', :to => 'proc_status_viewer#index' 
get 'proc_status_viewer_view', :to => 'proc_status_viewer#view' 
match 'proc_status_viewer/:type', :controller => 'proc_status_viewer', :action => 'index', :via => :get

