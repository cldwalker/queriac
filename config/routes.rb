ActionController::Routing::Routes.draw do |map|
  map.resources :commands, :member => { :import => :get }
  map.resources :users, :sessions
  map.resources :commands, :member => { :execute => :get }
    
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'

  map.account ':login/account', :controller => 'users', :action => 'account'


  map.connect 'help', :controller => 'static', :action => 'help'
  map.connect 'tutorial', :controller => 'static', :action => 'tutorial'

  # map.user '/rss/:login', :controller => 'users', :action => 'show'
  map.user ':login', :controller => 'users', :action => 'show'
  map.tag ':login/tag/:tag', :controller => 'users', :action => 'show'

  map.user ':login/commands', :controller => 'commands', :action => 'index'
  
  map.query ':login/:command/queries', :controller => 'queries', :action => 'index'
  map.query':login/queries', :controller => 'queries', :action => 'index'
  
  map.command ':login/:command/show', :controller => 'commands', :action => 'show'  
  map.command ':login/:command/edit', :controller => 'commands', :action => 'edit'
  map.command ':login/:command/delete', :controller => 'commands', :action => 'destroy', :method => :delete
  map.command ':login/*command', :controller => 'commands', :action => 'execute'
  
  
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "static", :action => "home"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id', :uri => /.+,/
  
  
  
end
