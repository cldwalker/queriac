module PathHelper
  #NOTE: these methods are regenerated every time this file is loaded
  tagged_methods = %w{tagged_user_commands_path user_tagged_queries_path tagged_commands_path}
  tagged_methods.each do |m|
    class_eval %[
      def #{m}(*args)
        unless args[0].is_a?(Hash)
          tags = args.pop
          tags = tags.to_a.join('+')
          args << tags
        end
        super(*args)
      end
    ]
  end
  
  #most methods below are convenience methods 
  #ie specify command instead of user + command  
  def public_user_command_path(*args)
    args[0].is_a?(UserCommand) ? super(args[0].user, args[0]) : super(*args)
  end
  
  def help_public_user_command_path(*args)
    args[0].is_a?(UserCommand) ? super(args[0].user, args[0]) : super(*args)
  end
  
  def copy_user_command_path(*args)
    args[0].is_a?(UserCommand) ? super(:id=>args[0].id) : super(*args)
  end
  
  def subscribe_user_command_path(*args)
    args[0].is_a?(UserCommand) ? super(:id=>args[0].id) : super(*args)
  end
  
  def user_command_queries_path(*args)
    args[0].is_a?(UserCommand) ? super(args[0].user, args[0]) : super
  end
  
  def user_default_command_path(user, query)
    "/#{user.login}/default_to #{user.default_command.keyword} #{query}"
  end
  
  #remove these if '/' isn't needed at the end
  def opensearch_user_url(*args)
    super + '/'
  end
  def opensearch_user_path(*args)
    super + '/'
  end
end