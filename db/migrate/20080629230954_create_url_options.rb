class CreateUrlOptions < ActiveRecord::Migration
  def self.up
    add_column :user_commands, :url_options, :text
    add_column :commands, :url_options, :text
  end

  def self.down
    remove_column :user_commands, :url_options
    remove_column :commands, :url_options
  end
end
