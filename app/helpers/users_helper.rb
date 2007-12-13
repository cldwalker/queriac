module UsersHelper
  
  def owner?
    @user == current_user
  end
    
end