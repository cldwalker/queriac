module PathHelper
  #NOTE: these methods are regenerated every time this file is loaded
  tagged_methods = %w{user_tagged_commands_path user_tagged_queries_path tagged_queries_path tagged_commands_path}
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
  
  #command* methods are convenience methods for having to only specify command instead of user + command
  def command_show_path(*args)
    args[0].is_a?(Command) ? user_command_path(args[0].user, args[0].keyword) : user_command_path(*args)
  end
  
  def command_edit_path(*args)
    args[0].is_a?(Command) ? user_command_edit_path(args[0].user, args[0].keyword) : user_command_edit_path(*args)
  end
  
  def command_delete_path(*args)
    args[0].is_a?(Command) ? user_command_delete_path(args[0].user, args[0].keyword) : user_command_delete_path(*args)
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