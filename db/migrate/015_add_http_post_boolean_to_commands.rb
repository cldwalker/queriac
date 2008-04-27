class AddHttpPostBooleanToCommands < ActiveRecord::Migration
  def self.up
    add_column :commands, :http_post, :boolean, :default => false
  end

  def self.down
    remove_column :commands, :http_post
  end
end
