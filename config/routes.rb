if Rails::VERSION::MAJOR >= 3
  RedmineApp::Application.routes.draw do
    resources :weekly_time_sheet
    match 'weekly_time_sheet' => 'weekly_time_sheet#index'
    match 'delete_time' => 'weekly_time_sheet#delete_time'
    match 'delete_time/:id' => 'weekly_time_sheet#delete_time'
    match 'project_tasks' => 'weekly_time_sheet#project_tasks'
    match 'project_tasks/:id' => 'weekly_time_sheet#project_tasks'
    match 'submit_time' => 'weekly_time_sheet#submit_time'
  end
else
  ActionController::Routing::Routes.draw do |map|
    map.resources :weekly_time_sheet
    map.connect 'weekly_time_sheet', :controller => 'weekly_time_sheet', :action => 'index'
    map.connect 'delete_time', :controller => 'weekly_time_sheet', :action => 'delete_time'
    map.connect 'project_tasks/:id', :controller => 'weekly_time_sheet', :action => 'project_tasks'
    map.connect 'submit_time', :controller => 'weekly_time_sheet', :action => 'submit_time'
  end
end
