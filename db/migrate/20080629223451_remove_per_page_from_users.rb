class RemovePerPageFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :per_page
  end

  def self.down
    add_column :users, :per_page, :integer
  end
end
