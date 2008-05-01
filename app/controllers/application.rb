# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable, PathHelper
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_queriac_session_id'
  
  include AuthenticatedSystem
  before_filter :login_from_cookie

  protected
  
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
    if @user.nil?
      flash[:warning] = "The user '#{params[:login]}' doesn't exist."
      redirect_to home_path
      return false
    end
    true
  end
  
  #this won't redirect actions that don't need params[:login] to be reached ie commands/index
  def redirect_invalid_user
    if @user.nil? && ! params[:login].nil?
      flash[:warning] = "The user '#{params[:login]}' doesn't exist."
      redirect_to home_path
      return false
    end
    true
  end
  
  def owner?
    logged_in? && current_user == @user
  end
  
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
          redirect_path = @user ? user_commands_path(@user) : commands_path
        end
        redirect_to redirect_path
        return
      end
    end
  end
end
