class AlterExistingColumns < ActiveRecord::Migration
  def self.up
    rename_column :commands, :modified_at, :updated_at
    rename_column :queries, :command_id, :user_command_id
    change_column :queries, :user_command_id, :integer
  end

  def self.down
    rename_column :commands, :updated_at, :modified_at
    rename_column :queries, :user_command_id, :command_id
    change_column :queries, :user_command_id, :string
  end
end
