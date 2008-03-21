ActionController::Routing::Routes.draw do |map|
  map.resources :commands, :member => { :import => :get }
  map.resources :users, :sessions
  map.resources :commands, :member => { :execute => :get }
    
  map.activate  '/activate/:activation_code',     :controller => 'users', :action => 'activate'
  map.account   ':login/account',                 :controller => 'users', :action => 'account'

  map.connect   'settings',                       :controller => 'users', :action => 'edit'
  map.connect   'help',                           :controller => 'static', :action => 'help'
  map.connect   '',                               :controller => "static", :action => "home"


  # map.user '/rss/:login', :controller => 'users', :action => 'show'
  map.query     'queries',                        :controller => 'queries', :action => 'index'

  map.user      ':login',                         :controller => 'users', :action => 'show'
  

  map.query     'queries/tag/*tag',               :controller => 'queries', :action => 'index'
  map.query     ':login/:command/queries',        :controller => 'queries', :action => 'index'
  map.query     ':login/queries',                 :controller => 'queries', :action => 'index'
  map.query     ':login/queries/tag/*tag',        :controller => 'queries', :action => 'index'
  
  map.command   'commands',                       :controller => 'commands',  :action => 'index'
  map.command   'commands/tag/*tag',              :controller => 'commands',  :action => 'index'
  map.command   ':login/commands',                :controller => 'commands',  :action => 'index'
  map.command   ':login/commands/tag/*tag',       :controller => 'commands',  :action => 'index'
  
  map.command   ':login/:command/show',           :controller => 'commands', :action => 'show'  
  map.command   ':login/:command/edit',           :controller => 'commands', :action => 'edit'
  map.command   ':login/:command/delete',         :controller => 'commands', :action => 'destroy', :method => :delete
  map.command   ':login/*command',                :controller => 'commands', :action => 'execute'  
  
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id', :uri => /.+,/  
  
end
