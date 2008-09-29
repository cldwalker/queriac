class AddUsersCountToCommands < ActiveRecord::Migration
  def self.up
    add_column :commands, :users_count, :integer, :default=>0
  end

  def self.down
    remove_column :commands, :users_count
  end
end
