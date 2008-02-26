module CommandsHelper
  
  def owner? command
    command.user == current_user
  end

end
