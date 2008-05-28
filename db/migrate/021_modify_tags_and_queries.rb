class ModifyTagsAndQueries < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      make_user_command_tags
      make_queries
      update_command_counts
    end
  end
  
  def self.update_command_counts
    count_sql = %[SELECT user_commands.command_id, count(*) as query_count FROM temp_queries INNER JOIN user_commands ON (temp_queries.command_id = user_commands.id) group by user_commands.command_id]
    records = UserCommand.find_by_sql(count_sql)
    records.each do |uc|
      begin
        uc.temp_command.update_attribute(:queries_count_all, uc['query_count'])
      rescue
        logger "FAILED_UPDATE for command count\ntemp_command id and query count: #{uc['command_id']}, #{uc['query_count']})"
      end
    end
  end
  
  def self.make_queries
    records = []
    
    #filters out ~160 queries that are causing hard to debug INSERT errors, will manually include 'em later
    Query.find(:all, :conditions=>%[query_string NOT REGEXP "'" AND query_string NOT REGEXP '\\\\\\\\']).each do |e|
      if (cid = old_to_new_commands[e.command_id.to_i])
        records << [cid, e.query_string, e.created_at, e.user_id, e.run_by_default, e.referrer]
      elsif e.command_id.to_i == 112
        #translating zeke's failing commands
        records << ['111', e.query_string, e.created_at, e.user_id, e.run_by_default, e.referrer]
      else
        unless deprecated_command_ids.include?(e.command_id.to_i)
          logger "NO_COMMAND_FOUND for command id(#{e.command_id}) and query record: #{e.inspect}"
        end
      end
    end
    records.map! do |e|
      #[integer_string, string, datetime, integer, boolean, string]
      record_string = [e[0], string_to_db(e[1]), "'#{e[2].to_s(:db)}'", (e[3].nil? ? "NULL" : e[3]), e[4].to_s, string_to_db(e[5])].join(',')
      %[(#{record_string})]
    end
    
    records.in_groups_of(5000)  do |group|
      insert_sql = %[INSERT INTO temp_queries (command_id, query_string, created_at, user_id, run_by_default, referrer) VALUES #{group.compact.join(",\n")};]
      #logger "INSERT SQL:\n#{insert_sql}\n\n\n"
      ActiveRecord::Base.connection.execute insert_sql
    end
  end
  
  def self.make_user_command_tags
    records = []
    Tagging.find(:all).each do |t|
      if (tid = old_to_new_commands[t.taggable_id])
        #Tagging.create('tag_id'=>t.id, 'taggable_type'=>'UserCommand', 'taggable_id'=>tid)
        records << [t.tag_id, 'UserCommand', tid]
      else
        unless (deprecated_command_ids + [112, 1292]).include?(t.taggable_id)
          logger "NO_COMMAND_FOUND for command id(#{t.taggable_id}) and tagging record: #{t.inspect}"
        end
      end
    end
    records.map! {|e| record_string = [e[0], "'#{e[1]}'", e[2]].join(',');  %[(#{record_string})]}
    insert_sql = %[INSERT INTO taggings (tag_id, taggable_type, taggable_id) VALUES #{records.compact.join(",\n")};]
    #logger "INSERT SQL:\n#{insert_sql}\n\n\n"
    ActiveRecord::Base.connection.execute insert_sql
  end
  
  def self.deprecated_command_ids
    @deprecated_command_ids ||= Command.find(:all, :conditions=>{:url=>deprecated_command_urls}, :select=>'url, id').map(&:id)
  end
  
  #copied from previous migration
  def self.deprecated_command_urls
    ["http://queri.ac/ghorner/commands/search?q=(q)", "http://queri.ac/zeke/commands/search?q=(q)", "http://queri.ac/sage/commands/search?q=(q)",
      "http://queri.ac/commands/tag_set?v=(q)", "http://queri.ac/commands/tag_add_remove?v=(q)"]
  end
  
  def self.logger(*args)
    puts *args
    #ActiveRecord::Base.logger.error(*args)
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
  
  def self.string_to_db(string)
    #string.nil? ? "NULL" : %['#{string.gsub("'", "\\\\'")}']
    #string.nil? ? "NULL" : %[QUOTE('#{string.gsub('\\', '\\\\\\')}')]
    string.nil? ? "NULL" : %['#{string}']
  end
  
  def self.down
  end
end
