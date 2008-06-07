class CleanupCommandsMigration < ActiveRecord::Migration
  def self.up
    replace_command_and_queries_with_temp_tables
    update_default_commands
    add_indexes
  end
  
  def self.replace_command_and_queries_with_temp_tables
    ActiveRecord::Base.connection.execute %[ALTER table commands rename to old_commands]
    ActiveRecord::Base.connection.execute %[ALTER table queries rename to old_queries]
    ActiveRecord::Base.connection.execute %[ALTER table temp_commands rename to commands]
    ActiveRecord::Base.connection.execute %[ALTER table temp_queries rename to queries]
  end
  
  def self.update_default_commands
    User.find(:all, :conditions=>'default_command_id IS NOT NULL').each do |u|
      if (new_id = old_to_new_commands[u.default_command_id])
        u.update_attribute :default_command_id, new_id
      else
        puts "Didn't update default_command_id for user #{user.login} with default command id #{u.default_command_id}"
      end
    end
  end
  
  def self.add_indexes
    add_index "queries", ["user_id"]
    add_index "queries", ["created_at"]
    add_index "queries", ["command_id"]
    add_index "user_commands", ["command_id"]
  end
  
  def self.old_to_new_commands
    unless @old_to_new_commands
      @old_to_new_commands = {}
      UserCommand.find(:all, :select=>'id,old_command_id').each do |e|
        @old_to_new_commands[e.old_command_id] = e.id
      end
        
    end
    @old_to_new_commands
  end
  
  def self.down
  end
end
