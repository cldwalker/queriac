class AddUrlEncodeBooleanToCommands < ActiveRecord::Migration
  def self.up
    add_column :commands, :url_encode, :boolean, :default => true
  end

  def self.down
    remove_column :commands, :url_encode
  end
end
