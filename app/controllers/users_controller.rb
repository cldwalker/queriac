
class UsersController < ApplicationController
  before_filter :login_required, :only => [:account]

  def new
  end
  
  def account    
    @user = User.find :first, :conditions => ['login = ?', params[:login]]

    # TODO: Build form for editing account
  end

  def show
    @user = User.find :first, :conditions => ['login = ?', params[:login]]
    find_type = (current_user == @user) ? "find" : "find_public"

    @commands = @user.commands.send find_type, :all, {:order => "modified_at DESC", :include => [:user]}
    
    @tag = params[:tag]
    @tags = @user.tags
    
    # TODO: Fix this. It's lame    
    @commands.reject!{|c| !c.tag_list.include? @tag} if @tag
    
    
    # Find most-queried commands
    # grouped = @user.queries.find(:all, :select => [:command_id]).group_by(&:command_id)
    # sorted = grouped.sort { |a,b| a[1].size <=> b[1].size }.reverse
    # command_ids = []
    # 0.upto(19) { |i| command_ids << sorted[i][0] }
    # @popular_commands = Command.find(command_ids).sort { |a,b| a.queries.size <=> b.queries.size }.reverse

    
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
