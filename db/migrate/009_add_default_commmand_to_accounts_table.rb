class AddDefaultCommmandToAccountsTable < ActiveRecord::Migration
  def self.up
    add_column :users, :default_command, :integer
  end

  def self.down
    remove_column :users, :default_command
  end
end
