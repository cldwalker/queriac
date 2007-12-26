class AddMoreSettingsToUsers < ActiveRecord::Migration
  def self.up
    rename_column :users, :default_command, :default_command_id
    add_column :users, :per_page, :integer
  end

  def self.down
    rename_column :users, :default_command_id, :default_command
    remove_column :users, :per_page
  end
end
