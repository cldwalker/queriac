ActionController::Routing::Routes.draw do |map|
  map.resources :commands, :member => { :execute => :get } , :collection=>{:tag_set=>:get, :tag_add_remove=>:get,
    :copy_yubnub_command=>:get}
  map.resources :sessions
  map.resources :users, :member => { :opensearch => :get }
    
  map.activate  '/activate/:activation_code',     :controller => 'users', :action => 'activate'
  #map.account   ':login/account',                 :controller => 'users', :action => 'account'
  map.settings   'settings',                      :controller => 'users', :action => 'edit'
  map.connect   'tutorial',                       :controller => 'users', :action => 'edit'
  map.help      'help',                           :controller => 'static', :action => 'help'
  map.home      '',                               :controller => "static", :action => "home"
  map.queries     'queries',                      :controller => 'queries', :action => 'index'
 
  map.with_options(:controller=>'users') do |c|
    c.user_home           ':login',                         :action => 'show'
    c.opensearch_user     ':login/opensearch',              :action => 'opensearch'
  end

  map.with_options(:controller=>'queries', :action=>'index') do |c|
    c.tagged_queries        'queries/tag/*tag'
    c.user_command_queries  ':login/:command/queries'
    c.user_queries          ':login/queries'
    c.user_tagged_queries   ':login/queries/tag/*tag'
  end
  
  map.with_options(:controller=>'commands') do |c|
    c.tagged_commands           'commands/tag/*tag',              :action => 'index'
    c.user_commands             ':login/commands',                :action => 'index'
    c.user_tagged_commands      ':login/commands/tag/*tag',       :action => 'index'
    c.search_user_commands      ':login/commands/search',         :action => 'search'

    c.user_command              ':login/:command/show',           :action => 'show'  
    c.user_command_edit         ':login/:command/edit',           :action => 'edit'
    c.user_command_delete       ':login/:command/delete',         :action => 'destroy', :method => :delete
    c.user_command_execute      ':login/*command',                :action => 'execute'  
  end
  
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id', :uri => /.+,/  
  
end
