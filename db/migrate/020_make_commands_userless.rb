class MakeCommandsUserless < ActiveRecord::Migration
  def self.up
    migrate_data
  end

  def self.migrate_data
    ActiveRecord::Base.transaction do
      make_admin_user
      make_default_commands
      make_public_commands
      make_private_commands
    end
  end
  
  
  def self.make_admin_user
    @admin_user = User.create(:login=>'queriac', :email=>'queriac@queri.ac', :password=>'youknow', :password_confirmation=>'youknow')
    # @admin_user = User.new(:login=>'queriac', :email=>'queriac@queri.ac', :password=>'youknow', :password_confirmation=>'youknow')
    # @admin_user.send(:create_without_callbacks)
    @admin_user.activate
    @admin_user.update_attribute :is_admin, true
  end
  
  def self.make_default_commands
    all_commands = Command.find(:all)
    exception_urls = ["http://queri.ac/settings"]
    @old_default_urls = []
    default_commands_config.each do |config|
      if config[:old_url]
        related_commands = all_commands.select {|e| e.url =~ /#{config[:old_url]}/  && ! exception_urls.include?(e.url)}
        @old_default_urls += related_commands.map(&:url)
      else
        @old_default_urls += [config[:url]]
        related_commands = all_commands.select {|e| e.url == config[:url]}
      end
      tcommand_hash = config.slice(:name, :keyword, :description, :url).merge(:user_id=>@admin_user.id)
      tcommand = TempCommand.create(tcommand_hash)
      create_commands(related_commands, :tcommand=>tcommand, :tcommand_hash=>tcommand_hash)
      logger "Keyword: #{config[:keyword]}"
      logger "TempCommand count: #{TempCommand.count}; UserCommand count: #{UserCommand.count}"
    end
    @old_default_urls.flatten!
  end
   
  def self.make_private_commands
    private_commands = Command.find(:all, :conditions=>'public=0', :order=>'created_at ASC')
    private_commands = private_commands.select {|e| ! excluded_urls.include?(e.url) }
    logger "private size: #{private_commands.size}"
    private_commands.each do |c|
      create_commands([c])
    end
  end

  def self.deprecated_command_urls
    ["http://queri.ac/ghorner/commands/search?q=(q)", "http://queri.ac/zeke/commands/search?q=(q)", "http://queri.ac/sage/commands/search?q=(q)",
      "http://queri.ac/commands/tag_set?v=(q)", "http://queri.ac/commands/tag_add_remove?v=(q)"]
  end
  
  def self.excluded_urls
    unless @excluded_urls
      @excluded_urls = @old_default_urls + deprecated_command_urls
      logger "EXCLUDED URLS:\n#{@excluded_urls.inspect}"
      logger "SIZE: #{@excluded_urls.size}"
    end
    @excluded_urls
  end
  
  def self.make_public_commands
    unique_urls = Command.find(:all, :conditions=>"public=1", :select=>'DISTINCT url, public').map(&:url)
    unique_urls -= excluded_urls
    logger "unique public urls: #{unique_urls.size}"
    public_commands = Command.find(:all, :conditions=>'public=1', :order=>'created_at ASC')
    
    unique_urls.each do |url|
      url_commands = public_commands.select {|e| e.url == url}
      logger("No old commands for url: #{url}") if url_commands.empty?
      create_commands(url_commands)
    end
  end
  
  def self.create_commands(old_commands, options={})
    tcommand_fields = %w{url name description keyword public origin created_at http_post url_encode user_id}
    ucommand_fields = tcommand_fields - ['public'] + ['public_queries']
    
    if (first_command = old_commands[0])
      if options[:tcommand]
        tcommand_hash = options[:tcommand_hash]
        tcommand = options[:tcommand]
      else
        tcommand_hash = first_command.attributes.slice(*tcommand_fields)
        tcommand = TempCommand.create(tcommand_hash)
      end
      if tcommand.valid?
        old_commands.each do |c|
          ucommand_hash = c.attributes.slice(*ucommand_fields).merge('command_id'=>tcommand.id, 'url'=>tcommand.url, 'old_command_id'=>c.id, 'queries_count'=>c.queries_count_all)
          ucommand_hash.update('name'=>tcommand.name, 'description'=>tcommand.description, 'public_queries'=>c.public_queries) if options[:tcommand]
          ucommand = UserCommand.create(ucommand_hash)
          if !ucommand.valid?
            logger "INVALID_USER_COMMAND not created for url:#{first_command.url}\nargs:#{ucommand_hash.inspect}\nucommand:#{ucommand.inspect}\nerrors:#{ucommand.errors.inspect}"
          end
        end
      else
        logger "INVALID_COMMAND not created for url:#{first_command.url}\nargs:#{tcommand_hash.inspect}\ncommand:#{tcommand.inspect}\nerrors:#{tcommand.errors.inspect}"
      end
    end
  end
  
  def self.logger(*args)
    puts *args
    #ActiveRecord::Base.logger.error(*args)
  end
  
  def self.make_url(url_string)
    %[http://#{::HOST}/#{url_string}]
  end
  
  def self.default_commands_config
    [
      {
        :name => "Google Quicksearch", 
        :keyword => "g",
        :url => "http://www.google.com/search?q=(q)",
        :description => "Performs a basic Google search.",
        :tags=>'google'
      },
      {
        :name => "Gmail Search", 
        :keyword => "gms",
        :url => "http://mail.google.com/mail/?search=query&view=tl&start=0&init=1&fs=1&q=(q)",
        :description => "Search your Gmail. If you're not logged in you'll be directed to the Gmail login page.\n\nExamples\ngms dog\ngms is:starred mom\ngms label:todo",
        :tags=>'google gmail mail'
      },
      {
        :name => "Google \"I'm Feeling Lucky\" Wikipedia (en) search",
        :keyword => "w",
        :url => "http://www.google.com/search?btnI=I'm%20Feeling%20Lucky&q=site:en.wikipedia.org%20(q)",
        :description => "Jumps to Google's first search result for the query you've entered + site:en.wikipedia.org\n\nExample: w colonel sanders",
        :tags=>'google wikipedia'
      },
      {
        :name => "Dictionary Lookup at Reference.com",
        :keyword => "word",
        :url => "http://www.reference.com/browse/all/(q)",
        :description => "Look up word definitions\n\nExample: word peripatetic",
        :tags=>"dictionary reference language english"
      },
      {
        :name => "My Queriac Page",
        :keyword => "q",
        :url=>make_url('home'),
        :old_url=>'queri.ac\/\w+$',
        :description => "A shortcut to my queriac account page.",
        :tags=>"queriac bootstrap"
      },
      {
        :name => "Show a Queriac user command",
        :keyword => "show",
        :url=>make_url('user_commands/(q)'),
        :old_url=>'queri.ac\/.*show$',
        :description => "Show info on a user command.\n\nExample: show g",
        :tags=>"queriac bootstrap"
      },
      {
        :name => "Edit a Queriac user command",
        :keyword => "edit",
        :url=>make_url('user_commands/(q)/edit'),
        :old_url=>'queri.ac\/.*edit$',
        :description => "Edit a user command.\n\nExample: edit g",
        :tags=>"queriac bootstrap"
      },
      {
        :name => "Create a new Queriac user command",
        :keyword => "new",
        :url=>make_url('user_commands/new'),
        :old_url=>'queri.ac\/commands\/new$',
        :description => "Create a new user command.",
        :tags=>"queriac bootstrap"
      },
      # {
      #   :name => "Delete a Queriac user command",
      #   :keyword => "delete",
      #   :url=>make_url('user_commands/(q)/destroy'),
      #   :description => "Delete a user command.\n\nExample: delete g",
      #   :tags=>"queriac bootstrap"
      # },    
      # {
      #   :name=>'Search my commands by url or keyword with regex',
      #   :keyword=>'search',
      #   :url=>make_url('user_commands/search?q=(q)'),
      #   :description=>"Searches my commands by url or keyword using regular expressions\r\n.\r\n\r\nExamples:\r\n#returns commands that have web in url or keyword \r\n#qs web\r\n\r\n#returns commands that have url or keyword starting with dw\r\nqs ^dw\r\n\r\n#returns commands that have url or keyword ending with ed\r\nqs ed$"
      # },
      # {
      #   :name=>"Add and/or remove tags to Queriac user commands",
      #   :keyword=>'tar',
      #   :url=>make_url('user_commands/tag_add_remove?v=(q)'),
      #   :description=>"Usage: tset keyword(s) tag(s)\r\n* keyword(s) can be a single keyword or a comma delimited group of keywords (no spaces)\r\n* tag(s) can be a single tag or a space delimited group of tags. By default tags are added\r\nto the given keywords. To indicate a tag should be removed put a hyphen '-' in front of it.\r\nYou can mix tags to be added and removed in the same command. \r\n\r\nExamples:\r\n#add tag search and remove tag google to command g\r\ntset  g search -google\r\n\r\n#remove tags yahoo and search and add tag yub to commands y and yb\r\ntset y,yb -yahoo -search yub"
      # },
      # {
      #   :name=>'Replace tags of Queriac user commands',
      #   :keyword=>'tset',
      #   :url=>make_url('user_commands/tag_set?v=(q)'),
      #   :description=>"Usage: tset keyword(s) tag(s)\r\n* keyword(s) can be a single keyword or a comma delimited group of keywords (no spaces)\r\n* tag(s) can be a single tag or a space delimited group of tags\r\n\r\nExample: \r\n#replace tags of commands, urban and gd, with dictionary and awesome\r\ntset urban,gd dictionary awesome"
      # }
    ]
  end
  
  def self.down
  end
end
