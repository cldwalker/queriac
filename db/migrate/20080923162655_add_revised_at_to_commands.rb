class AddRevisedAtToCommands < ActiveRecord::Migration
  def self.up
    add_column :commands, :revised_at, :datetime
  end

  def self.down
    remove_column :commands, :revised_at
  end
end
