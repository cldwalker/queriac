module UsersHelper
  
  def current_user_is_the_user?
    @user == current_user
  end
  
  def whose
    @user == current_user ? "your" : "#{@user.login}'s"
  end
    
end