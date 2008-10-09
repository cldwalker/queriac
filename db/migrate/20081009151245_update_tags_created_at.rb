class UpdateTagsCreatedAt < ActiveRecord::Migration
  def self.up
    Tag.find(:all).each do |t|
      if (user_command = t.user_commands.find(:first, :order=>"created_at ASC"))
        t.update_attribute :created_at, user_command.created_at
      elsif (command = t.commands.find(:first, :order=>"created_at ASC"))
        t.update_attribute :created_at, command.created_at
      end
    end
  end

  def self.down
  end
end
