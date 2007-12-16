
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
    
    @tag = params[:tag]
    @tags = @user.tags
    
    @commands = @user.commands.send find_type, :all, {:order => "modified_at DESC", :include => [:user]}
    
    # TODO: Fix this. It's lame    
    @commands.reject!{|c| !c.tag_list.include? @tag} if @tag
    
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

  def activate
    self.current_user = User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.activated?
      current_user.activate
      flash[:notice] = "Account activation complete! You are now logged in."
    end
    redirect_to "/setup"
  end

end
