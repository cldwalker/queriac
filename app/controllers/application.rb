# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_queriac_session_id'
  
  include AuthenticatedSystem
  before_filter :login_from_cookie
  
  def load_user
    @user = (logged_in? && current_user.login==params[:login]) ? current_user : User.find_by_login(params[:login])    
  end
  
  def owner?
    logged_in? && current_user == @user
  end
  
end
