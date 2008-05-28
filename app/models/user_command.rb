class UserCommand < ActiveRecord::Base
  belongs_to :user
  belongs_to :command
  belongs_to :temp_command, :foreign_key=>'command_id'
  belongs_to :old_command, :class_name=>'Command'
  has_many :queries, :dependent => :destroy, :foreign_key=>'command_id'
  has_many :temp_queries, :dependent => :destroy, :foreign_key=>'command_id'
  acts_as_taggable
  validates_presence_of :user_id, :keyword, :name, :url
  validates_presence_of :command_id, :message=>"couldn't be created. Our support team has been notified and should contact you promptly.",
    :unless=>Proc.new {|uc| uc.errors.size > 0}
  validates_uniqueness_of :keyword, :scope => :user_id
  validates_uniqueness_of :command_id, :scope=>:user_id, :message=>'is already created for this user.'
  validates_uniqueness_of :name, :scope=>:user_id
  #CHANGE
  #attr_protected :user_id
  
  COMMAND_JOIN_SQL = "JOIN commands ON (commands.id = user_commands.command_id)"
  has_finder :used, :conditions => ["user_commands.queries_count >= 0"]
  # has_finder :unused, :conditions => ["commands.queries_count_all = 0"]
  # has_finder :popular, :conditions => ["commands.queries_count_all > 50"]
  has_finder :public, :conditions=>'commands.public = 1', :joins=>COMMAND_JOIN_SQL
  has_finder :publicly_queriable, :conditions => {:public_queries => true}
  has_finder :quicksearches, :conditions => ["commands.kind ='parametric' AND bookmarklet=0"], :joins=>COMMAND_JOIN_SQL
  has_finder :bookmarklets, :conditions => ["bookmarklet=1"], :joins=>COMMAND_JOIN_SQL
  has_finder :shortcuts, :conditions => ["commands.kind ='shortcut' AND bookmarklet=0"], :joins=>COMMAND_JOIN_SQL
  has_finder :any
  COMMAND_FIELDS = %w{url http_post url_encode public origin}
  COMMAND_ONLY_FIELDS = %w{public origin}
  
  def validate
    if self.keyword && STOPWORDS.include?(self.keyword.downcase)
      errors.add_to_base "Sorry, the keyword you've chosen (#{self.keyword}) is reserved by the system. Please use something else." 
    end
  end
  
  def after_validation
    self.keyword.downcase! if self.keyword
    #self.url.sub!('%s', DEFAULT_PARAM )
  end
  
  #CHANGE
  # def initialize(*args)
  #   #p args[0]
  #   if args[0].is_a?(Hash)
  #     args[0].stringify_keys! #in case it's not an insensitive hash
  #     command_hash = args[0].slice(*COMMAND_FIELDS)
  #     args[0].except!(*COMMAND_ONLY_FIELDS)
  #   end
  #   super(*args)
  #   # p command_hash
  #   # p args[0]
  #   if self.command_id.nil? && self.command.nil?
  #     create_command_from_hash(command_hash) 
  #   else
  #     self.url = self.command.url
  #   end
  #   return self
  # end
    
  def create_command_from_hash(command_hash)
    if command_hash
      #if desired command is public, look for existing command
      if ['1', true].include?(command_hash[:public]) && (existing_command = Command.find_by_url_and_public(command_hash[:url], true))
        self.command = existing_command
      else
        begin
          self.command = Command.create({:user_id=>user_id, :name=>name}.update(command_hash))
        rescue
          logger.error "Command creation failed for user_command: #{self.inspect}\n #{$!}"
        end
      end
    end
  end
  
  def update_all_attributes(hash, current_user)
    disabled_fields = get_disabled_update_fields(current_user)
    hash.except!(*disabled_fields)
    if update_attributes(hash.except(*COMMAND_ONLY_FIELDS))
      if self.command_owned_by?(current_user)
        self.command.update_attributes(hash.slice(*COMMAND_FIELDS))
      end
      return true
    else
      return false
    end
  end
  
  def get_disabled_update_fields(current_user)
    disabled_fields = [:public, :url]
    disabled_fields.delete(:url) if self.command_owned_by?(current_user)
	  disabled_fields.delete(:public) if self.command_owned_by?(current_user) && self.command_editable?
	  disabled_fields
  end
  
  def update_query_counts
    self.update_attribute(:queries_count, queries.count)
  end

  def public; new_record? ? true : command.public; end
  delegate :public?, :favicon_url, :domain, :to=>:command
  delegate :url_for, :to=>:command #hack?
  def private?; !command.public?; end
  def public_queries?; self.public && self.public_queries; end
  
  def command_url_changed?
    self.command.url != self.url
  end
  
  def update_url
    self.update_attribute(:url, self.command.url)
  end
  
  def command_editable?; command.users.size <= 1; end
  def owned_by?(possible_owner); self.user == possible_owner; end
  def command_owned_by?(possible_owner)
    self.command.user == possible_owner
  end
  
  def update_tags(tags)
    self.tag_list = tags.split(" ").join(", ")
    self.save
  end
  
  def tag_string
    self.tag_list.join(" ")
  end
  
end