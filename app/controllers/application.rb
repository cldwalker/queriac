# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable, PathHelper, SharedHelper
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_queriac_session_id'
  filter_parameter_logging 'password'
  
  include AuthenticatedSystem
  before_filter :login_from_cookie

  def allow_breadcrumbs
    @breadcrumbs_allowed = true
  end
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
  
  def set_command
    #   action_include_hash = {'edit'=>[:user], 'destroy'=>[:queries]} for /commands
    #   @command = @user.commands.find_by_keyword(params[:command], :include=>action_include_hash[self.action_name] || [])
    @command = Command.find_by_keyword_or_id(params[:id])
    if @command.nil?
      flash[:warning] = "Command '#{params[:id]}' not found."
      redirect_back_or_default commands_path
      return false
    else
      if @command.private? && ! command_owner_or_admin?
        flash[:warning] = "Sorry, the command '#{@command.keyword}' is private."
        redirect_back_or_default user_home_path(@command.user)
        return false
      end
    end
    true
  end
  
  def user_command_is_nil?(attempt=nil)
    if @user_command.nil?
      flash[:warning] = %[User command #{"'#{attempt}'" if attempt} not found.]
      redirect_to user_commands_path
      return true
    else
      return false
    end
  end
  
end
