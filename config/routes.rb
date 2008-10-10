ActionController::Routing::Routes.draw do |map|
  map.connect  'commands/new', :controller=>'commands', :action=>'show', :id=>'new'
  map.command_type_commands 'commands/:type', :controller=>'commands', :action=>'index', :type=>/#{Command::TYPES.join("|")}/
  map.resources :commands, :member => { :execute => :get } , :collection=>{:search_all=>:get, :tag_set=>:get, :tag_add_remove=>:get,
     :find_by_ids=>:get, :header_search=>:get}
  #tagged_commands needs to be after map.resources :commands to allow for commands/tag
  map.tagged_commands 'commands/tag/*tag', :controller=>'commands', :action=>'tagged_commands'
  map.resources :sessions
  map.resources :user_commands, :member=>{:subscribe=>:get, :copy=>:get, :update_url=>:post, :destroy=>:get}, 
    :collection=>{:import=>:any, :tag_set=>:get, :tag_add_remove=>:get, :search=>:get, :copy_yubnub_command=>:get,
      :change_option_type_fields=>:post, :update_default_picker=>:post, :sync_url_options=>:post, :fetch_form=>:any,
      :fetch_and_sync_url_options=>:post
  }
  map.resources :tags
  
  map.with_options(:controller=>'user_commands') do |c|
    c.command_user_commands  'commands/:id/user_commands', :action=>'command_user_commands'
    c.formatted_command_user_commands  'commands/:id/user_commands.:format', :action=>'command_user_commands', :format=>'rss'
    # c.formatted_tagged_user_commands   ':login/user_commands/tag/*tag.:format',   :action=>'index', :format=>'rss'
    c.tagged_user_commands   ':login/user_commands/tag/*tag',   :action=>'index'
    c.old_tagged_user_commands   ':login/commands/tag/*tag',   :action=>'old_index'
    # c.formatted_all_tagged_user_commands   'user_commands/tag/*tag.:format',   :action=>'index', :format=>'rss'
    c.all_tagged_user_commands   'user_commands/tag/*tag',   :action=>'index'
    c.specific_user_commands   ':login/user_commands', :action=>'index'
    c.formatted_specific_user_commands   ':login/user_commands.:format', :action=>'index', :format=>/atom|rss|xml/
    #perhaps remove /show at end once other routes are stable + in right order
    c.public_user_command     ':login/:id/show', :action=>'show'
    c.help_public_user_command     ':login/:id/help', :action=>'help'
  end
  map.resources :users, :member => { :opensearch => :get }
    
  map.activate_user  '/activate/:activation_code',     :controller => 'users', :action => 'activate'
  map.settings    'settings',                     :controller => 'users', :action => 'edit'
  map.static_page    ':static_page',              :controller=>'static', :action=>'render_page', :static_page=>/#{STATIC_PAGES.join("|")}/
  map.home        '',                             :controller => "static", :action => "home"
  map.queries     'queries',                      :controller => 'queries', :action => 'index'
 
  map.with_options(:controller=>'users') do |c|
    c.current_user_home   'home',   :action=>'home'
    c.user_home           ':login',                         :action => 'show'
    c.opensearch_user     ':login/opensearch',              :action => 'opensearch'
  end
  
  map.with_options(:controller=>'queries') do |c|
    c.command_queries 'commands/:id/queries', :action=>'command_queries'
  end
  
  map.with_options(:controller=>'queries', :action=>'index') do |c|
    c.tagged_queries        'queries/tag/*tag'
    c.user_command_queries  ':login/:command/queries'
    c.user_queries          ':login/queries'
    c.user_tagged_queries   ':login/queries/tag/*tag'
  end
  
  map.with_options(:controller=>'commands') do |c|
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
