
class UsersController < ApplicationController
  before_filter :login_required, :only => [:account]
  before_filter :load_user, :only => [:show]

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
    
    # TODO: Fix this. It's lame
    @tag = params[:tag]
    # @commands.select!{|c| c.tags.map(&:name).include? @tag } if @tag
    
    @users = User.find(:all, :order => :login)
  end

  def create
    @user = User.new(params[:user])
    
    # unless params[:invite_code] == "dog"
    #   render :action => 'new'
    #   flash[:warning] = "Invalid invite code! Try again."
    #   return
    # end

      
    @user.save!
    # self.current_user = @user
    # redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up! Before you can log in, you'll have to verify your account by checking your email."
    # flash[:notice] = "Thanks for signing up! A few commands were automatically created for you to get you started.."
    redirect_to ""
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  def edit
    @user = current_user
    raise "You are not allowed to edit this user." if @user != current_user
  end
  
  
  def update
    @user = current_user

    respond_to do |format|
      
      params[:user][:default_command_id] = nil if params[:use_default_command] == "no"

      if @user.update_attributes(params[:user])
        flash[:notice] = "Your settings have been updated."
        format.html { redirect_to current_user.home_path }
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
    redirect_to "/tutorial"
  end

end
