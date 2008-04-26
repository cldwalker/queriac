# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_queriac_session_id'
  
  include AuthenticatedSystem
  before_filter :login_from_cookie

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
  
  def owner_required
    unless owner?
      flash[:warning] = "You are not allowed to administer this query. "
      if logged_in?
        redirect_to @user.home_path
      else
        flash[:warning] += "If it's your query, you'll need to log in to make any changes to it."
        redirect_to ""
      end
      return
    end
  end
  
  # Don't display private queries to anyone but their commands' owners.
  def check_command_query_publicity
    unless owner? || @command.public_queries?
      flash[:warning] = "Sorry, that command's queries are private. "
      if logged_in?
        redirect_to @user.home_path
      else
        flash[:warning] += "If it's your command, you'll need to log in to view its queries."
        redirect_to ""
      end
      return
    end
  end
  
end
