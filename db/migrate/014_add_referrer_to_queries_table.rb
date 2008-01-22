class AddReferrerToQueriesTable < ActiveRecord::Migration
  def self.up
    add_column :queries, :referrer, :text
  end

  def self.down
    remove_column :queries, :referrer
  end
end
