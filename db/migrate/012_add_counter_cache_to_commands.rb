class AddCounterCacheToCommands < ActiveRecord::Migration
  def self.up
    add_column :queries, :user_id, :integer
    add_column :queries, :run_by_default, :boolean, :default => false
    add_column :commands, :queries_count_all, :integer, :default => 0
    add_column :commands, :queries_count_owner, :integer, :default => 0
  end

  def self.down
    remove_column :queries, :user_id
    remove_column :queries, :run_by_default
    remove_column :commands, :queries_count_all
    remove_column :commands, :queries_count_owner
  end
end

# Run this post-migration
# User.find(:all).each {|u| u.commands.each{|c| c.queries.each{|q| q.update_attribute(:user_id, u.id)}}}
# Command.find(:all, :conditions => ["user_id IS NULL"]).map(&:destroy)
# Command.find(:all).each {|c| c.update_query_counts }
