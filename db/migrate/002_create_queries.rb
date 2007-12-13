class CreateQueries < ActiveRecord::Migration
  def self.up
    create_table :queries do |t|
      t.column :command_id, :string
      t.column :query_string, :string
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :queries
  end
end
