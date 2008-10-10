class RemoveOldCommandIdFromUserCommands < ActiveRecord::Migration
  def self.up
    remove_column :user_commands, :old_command_id
  end

  def self.down
    add_column :user_commands, :old_command_id, :integer
  end
end
