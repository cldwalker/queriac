class CreateCommands < ActiveRecord::Migration
  def self.up
    create_table :commands do |t|
      t.column :name, :string
      t.column :keyword, :string
      t.column :url, :string
      t.column :description, :text
      t.column :kind, :string
      t.column :origin, :string, :default => "hand"
      t.column :created_at, :datetime
      t.column :modified_at, :datetime
    end
  end

  def self.down
    drop_table :commands
  end
end
