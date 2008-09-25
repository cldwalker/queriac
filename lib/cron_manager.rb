class CronManager
  class << self
    def logger
      @periodic_logger ||= Logger.new("#{RAILS_ROOT}/log/cron.log")
    end

    def run
      logger.level = Logger::INFO
      logger.info("\n*** Starting Cron Manager at #{Time.now}")
      run_job(:update_commands_for_public)
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
      existing_command_ids = user.user_commands.map(&:command_id)
      new_commands = Command.public.select {|e| !existing_command_ids.include?(e.id)}
      valid_commands, invalid_commands =  new_commands.partition {|e| !e.keyword.nil?}
      logger.info("Can't create commands for the following keywordless commands: #{invalid_commands.map(&:id).inspect}")
      logger.info("Creating commands for the following command ids: #{valid_commands.map(&:id).inspect}")
      valid_commands.each do |c|
         user_command = user.subscribe_to(c)
         unless user_command.valid?
           logger.info("Failed to subscribed to command id #{c.id}: #{user_command.errors.inspect}")
         end
      end
    end
    
    # def update_user_commands_counts
    #   queries = Query.find(:all, :group=>'user_command_id', :select=>'user_command_id, count(*) as count')
    # end
  end
end