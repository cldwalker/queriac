class DropDeprecatedTables < ActiveRecord::Migration
  def self.up
    drop_table :old_commands
    drop_table :old_queries
    drop_table :temp_commands
    drop_table :temp_queries
    remove_column :user_commands, :old_command_id
  end

  def self.down
  end
end
