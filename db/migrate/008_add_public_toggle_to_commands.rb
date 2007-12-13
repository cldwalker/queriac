class AddPublicToggleToCommands < ActiveRecord::Migration
  def self.up
    add_column :commands, :public, :boolean, :default => true
    add_column :commands, :public_queries, :boolean, :default => true    
  end

  def self.down
    remove_column :commands, :public
    remove_column :commands, :public_queries
  end
end
