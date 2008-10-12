
class UsersController < ApplicationController
  before_filter :login_required, :only => [:edit, :destroy, :update, :home]
  before_filter :load_valid_user, :only=>:show
  before_filter :store_location, :only=>[:index, :show, :edit, :home]
  before_filter :load_user_from_param, :only => [:opensearch]
  before_filter :allow_breadcrumbs, :only=>[:index, :home, :edit, :show]
  verify :method=>:delete, :only=>:destroy
  
  def index
    pagination_params = {:order => "users.created_at DESC", :page => params[:page]}
    @users = User.paginate_users(pagination_params)
    User.set_queries_count_for_users(@users)
  end

  def new
  end
  
  def home
    @user = current_user
    show
    render :action=>'show'
  end
  
  def show
    publicity = (current_user? || admin?) ? "any" : "public"
    
    if @user.queries.count > 100
      @quicksearches, @shortcuts, @bookmarklets = @user.cached(:user_commands_by_type, :with=>publicity, :ttl=>15.minutes)
    else
      @user_commands = @user.user_commands.send(publicity).paginate(:page => params[:page], :order => "queries_count DESC", :include => [:user, :command])
    end
    
    @users = User.cached(:find_top_users)
    @commands_to_update = @user.user_commands.out_of_date if current_user?
  end
  
  def opensearch
    respond_to do |format|
      format.xml  { render :actions => "opensearch" }
    end
  end

  def create
    if (hidden_value = params[:user].delete(get_bot_param_for(:signup))) && ! hidden_value.blank?
      logger.info "BOT tried to signup with the value '#{hidden_value}' for the hidden field '#{get_bot_param_for(:signup)}'."
      render :action=>'new'
      return
    end
    
    @user = User.new(params[:user])      
    @user.save!
    flash[:notice] = "Thanks for signing up! Before you can log in, you'll have to verify your account by checking your email."
    redirect_to home_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  def edit
    @user = current_user
  end
  
  def update
    @user = current_user

    respond_to do |format|
      
      params[:user][:default_command_id] = nil if params[:use_default_command] == "no"

      if @user.update_attributes(params[:user])
        flash[:notice] = "Your settings have been updated."
        format.html { redirect_to user_home_path(current_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  def activate
    self.current_user = User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.activated?
      current_user.activate
      current_user.create_default_user_commands
      flash[:notice] = "Account activation complete! You are now logged in."
    else
      flash[:warning] = "Sorry, you are either already activated or have an invalid activation key."
    end
    redirect_to static_page_path('setup')
  end
  
  def destroy
    password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]
    if password == password_confirmation
      if current_user.authenticated?(password)
        current_user.destroy
        flash[:notice] = "Your account has been deleted. Sorry to see you go."
        redirect_to home_path
      else
        flash[:warning] = "Sorry, wrong password. Please try again."
        redirect_to settings_path
      end
    else
      flash[:warning] = "Your password and password confirmation weren't the same. Please try again."
      redirect_to settings_path
    end
  end

end
