module CommandsHelper
  
  def current_user_owns_command? command
    command.user == current_user
  end

end
