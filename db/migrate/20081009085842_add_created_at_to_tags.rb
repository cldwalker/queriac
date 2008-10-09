class AddCreatedAtToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :created_at, :datetime
  end

  def self.down
    remove_column :tags, :created_at
  end
end
