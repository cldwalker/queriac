# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable, PathHelper, SharedHelper
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_queriac_session_id'
  filter_parameter_logging 'password'
  
  include AuthenticatedSystem
  before_filter :login_from_cookie

  protected
  
  ####Methods below are used in before filters
  
  #load_valid_user* used to load @user in controllers
  def load_valid_user
    load_user_from_param
    redirect_no_user
  end
  
  def load_valid_user_if_specified
    load_user_from_param
    redirect_invalid_user
  end
  
  def load_user_from_param
    @user = (logged_in? && current_user.login==params[:login]) ? current_user : User.find_by_login(params[:login])
  end
  
  def redirect_no_user
    if @user.nil? || ! @user.activated?
      flash[:warning] = %[The user '#{params[:login]}' #{@user ? "hasn't been activated" : "doesn't exist"}.]
      redirect_to home_path
      return false
    end
    true
  end
  
  #this won't redirect actions that don't need params[:login] to be reached ie commands/index
  def redirect_invalid_user
    if ! params[:login].nil? && (@user.nil? || !@user.activated?)
      flash[:warning] = %[The user '#{params[:login]}' #{@user ? "hasn't been activated" : "doesn't exist"}.]
      redirect_to home_path
      return false
    end
    true
  end
  
  def admin_required
    if logged_in? && current_user.is_admin?
      return true
    else
      flash[:warning] = "Access denied!"
      redirect_to (logged_in? ? user_home_path(current_user) : home_path)
      return false
    end
  end
  
  #used to load @tags in controllers
  def load_tags_if_specified
    if params[:tag]
      if params[:tag].first
        @tags = params[:tag].first.gsub(" ", "+").split("+") 
      #handles nil tags ie /:user/commands/tag or /:user/queries/tag
      else
        flash[:warning] = 'No tag was specified. Please try again'
        if params[:controller] == 'queries'
          redirect_path = @user ? user_queries_path(@user) : queries_path
        else
          redirect_path = @user ? specific_user_commands_path(@user) : user_commands_path
        end
        redirect_to redirect_path
        return
      end
    end
  end
end
