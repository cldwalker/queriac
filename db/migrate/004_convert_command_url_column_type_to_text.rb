class ConvertCommandUrlColumnTypeToText < ActiveRecord::Migration
  def self.up
    change_column :commands, :url, :text
  end

  def self.down
    change_column :commands, :url, :string    
  end
end
