module UsersHelper
    
  def whose
    @user == current_user ? "your" : "#{@user.login}'s"
  end
    
end