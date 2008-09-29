class UpdateUsersCountsForCommands < ActiveRecord::Migration
  def self.up
    command_ids = UserCommand.find(:all, :group=>"command_id", :select=>"command_id, count(*) as users_count")
    command_ids.each {|e| e.command.update_attribute :users_count, e.users_count }
  end

  def self.down
    Command.update_all "users_count=0"
  end
end
