module CommandsHelper
  
  def owner?
    @command.user == current_user
  end

end
