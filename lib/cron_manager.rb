class CronManager
  class << self
    def logger
      @periodic_logger ||= Logger.new("#{RAILS_ROOT}/log/cron.log")
    end

    def run(dryrun=false)
      @dry_run = true if dryrun
      logger.level = Logger::INFO
      logger.info("\n*** Starting Cron Manager at #{Time.now}")
      run_job(:subscribe_to_new_commands_for_public)
      run_job(:update_commands_for_public)
      run_job(:sync_user_command_query_counts)
      run_job(:sync_command_query_counts)
      run_job(:check_for_unused_commands)
      logger.info("\n*** Ended Cron Manager at #{Time.now}")
    end
    
    def run_job(job_name)
      logger.info "Starting job #{job_name}"
      begin
        send(job_name)
      rescue
        logger.error("ERROR during job #{job_name} #{$!.inspect}\nTrace: #{$!.backtrace.slice(0,6).inspect}")
      end
      logger.info "Ended job #{job_name}"
    end
    
    def update_commands_for_public
      user = User.find_by_login 'public'
      out_of_date_commands = user.user_commands.out_of_date
      logger.info "Updating the following commands for public: #{out_of_date_commands.map(&:id).inspect}"
      return if @dry_run
      out_of_date_commands.each {|e| e.update_url_and_options}
    end
    
    def subscribe_to_new_commands_for_public
      user = User.find_by_login 'public'
      existing_command_ids = user.user_commands.map(&:command_id)
      new_commands = Command.public.select {|e| !existing_command_ids.include?(e.id)}
      valid_commands, invalid_commands =  new_commands.partition {|e| !e.keyword.nil?}
      logger.info("Can't create commands for the following keywordless commands: #{invalid_commands.map(&:id).inspect}")
      logger.info("Creating commands for the following command ids: #{valid_commands.map(&:id).inspect}")
      return if @dry_run
      valid_commands.each do |c|
         user_command = user.subscribe_to(c)
         unless user_command.valid?
           logger.info("Failed to subscribed to command id #{c.id}: #{user_command.errors.inspect}")
         end
      end
    end
    
    def sync_command_query_counts
      sums = UserCommand.find(:all, :group=>"command_id", :select=>"command_id, sum(queries_count) as sum")
      logger.info "Checking #{sums.size} command counts."
      sums.each do |e|
        command = e.command
        actual_count = e.sum.to_i
        if actual_count != command.queries_count_all
          logger.info "Command #{command.id}: cached/actual - #{command.queries_count_all}/#{actual_count}"
          unless @dry_run
            logger.info "Command #{command.id}: updating queries_count_all from #{command.queries_count_all} to #{actual_count}"
            command.update_attribute(:queries_count_all, actual_count)
          end
        end
      end
    end
    
    def sync_user_command_query_counts
      counts = Query.find(:all, :group=>'user_command_id', :select=>'user_command_id, count(*) as count')
      logger.info "Checking #{counts.size} user_command counts."
      counts.each do |q|
        user_command = q.user_command
        actual_count = q.count.to_i
        if actual_count != user_command.queries_count
          logger.info "UserCommand #{user_command.id}: cached/actual- #{user_command.queries_count}/#{actual_count}"
          unless @dry_run
            logger.info "UserCommand #{user_command.id}: updating queries_count from #{user_command.queries_count} to #{actual_count}"
            user_command.update_attribute(:queries_count, actual_count)
          end
        end
      end
    end
    
    def check_for_unused_commands
      used_command_ids = UserCommand.find(:all, :group=>"command_id", :select=>"command_id").map(&:command_id)
      unused_commands = Command.find(:all).select {|e| !used_command_ids.include?(e.id)}
      logger.info "Following commands are not used: #{unused_commands.map(&:id).inspect}"
    end
    
    # def check_for_private_commands_with_multiple_users
    # end
  end
end