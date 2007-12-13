# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(user_path(self.current_user.login))
      flash[:notice] = "Logged in successfully"
    else
      flash[:warning] = "Problem logging in. Please try again."
      render :action => 'new'
    end
  end

  def destroy
    # raise current_user.inspect
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to :action => 'new'
    # redirect_back_or_default(:action => 'new')
  end
end
