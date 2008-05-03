
class UsersController < ApplicationController
  before_filter :login_required, :only => [:destroy, :update]
  before_filter :load_valid_user, :only=>:show
  before_filter :load_user_from_param, :only => [:opensearch]

  def index
    pagination_params = {:order => "users.created_at DESC", :page => params[:page]}
    @users = User.paginate({:conditions => ["activation_code IS NULL"]}.merge(pagination_params))
  end

  def new
  end
  
  def show
    publicity = owner? ? "any" : "public"
    
    if @user.queries.count > 100
      @quicksearches = @user.commands.send(publicity).quicksearches.used.find(:all, {:order => "queries_count_all DESC", :include => [:user], :limit => 15})
      @shortcuts = @user.commands.send(publicity).shortcuts.used.find(:all, {:order => "queries_count_all DESC", :include => [:user], :limit => 15})
      @bookmarklets = @user.commands.send(publicity).bookmarklets.used.find(:all, {:order => "queries_count_all DESC", :include => [:user], :limit => 15})
    else
      @commands = @user.commands.send(publicity).paginate(:page => params[:page], :order => "queries_count_all DESC", :include => [:user])
    end
    
    @tags = @user.tags
    @users = User.find_top_users
  end
  
  def opensearch
    respond_to do |format|
      format.xml  { render :actions => "opensearch" }
    end
  end

  def create
    @user = User.new(params[:user])      
    @user.save!
    flash[:notice] = "Thanks for signing up! Before you can log in, you'll have to verify your account by checking your email."
    redirect_to home_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  def edit
    @user = current_user if logged_in?
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
      flash[:notice] = "Account activation complete! You are now logged in."
    end
    redirect_to settings_path
  end
  
  def destroy
    @user = current_user
    @user.destroy

    respond_to do |format|
      flash[:notice] = "Your account has been deleted. Sorry to see you go."      
      format.html { redirect_to home_path }
      format.xml  { head :ok }
    end
  end

end
