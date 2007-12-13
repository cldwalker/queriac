class AddBookmarkletFieldToCommandsTable < ActiveRecord::Migration
  def self.up
    add_column :commands, :bookmarklet, :boolean, :default => false    

    Command.find(:all).each do |c|
      c.save!
    end
    
  end

  def self.down
    remove_column :commands, :bookmarklet
  end
end
