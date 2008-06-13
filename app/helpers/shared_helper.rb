module SharedHelper
  #Permission methods
  def command_owner?
    logged_in? && @command.created_by?(current_user)
  end
  
  def admin?
    (logged_in? && current_user.is_admin?)
  end
  
  def command_owner_or_admin?
    command_owner? || admin?
  end

  #used where load_valid_user() and/or @user defined
  def current_user?(user=@user)
    logged_in? && current_user == user
  end
  
  def can_view_queries?
    user_command_owner? || @user_command.public_queries?
  end
  
  def user_command_owner?
    @user_command.owned_by?(current_user)
  end
  
  def user_command_owner_or_admin?
    user_command_owner? || admin?
  end
  
  def get_bot_param_for(action)
    unless @crypted_param
      action_salt = Digest::SHA1.hexdigest "--#{action}--"
      @crypted_param = Digest::SHA1.hexdigest "--#{action_salt}--#{Date.today}--"
    end
    @crypted_param
  end
end