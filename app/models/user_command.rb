class UserCommand < ActiveRecord::Base
  include CommandHelper
  belongs_to :user
  belongs_to :command
  has_many :queries, :dependent => :destroy
  
  acts_as_taggable
  validates_presence_of :user_id, :keyword, :name, :url
  validates_each :url_options do |record, attr, value|
    record.validate_url_options if record.has_options?
  end
  #command validation needs to be after the above validations which effect command creation
  validates_presence_of :command_id, :message=>"couldn't be created. Our support team has been notified and should contact you promptly.",
    :unless=>Proc.new {|uc| uc.errors.size > 0}
    
  validates_uniqueness_of :keyword, :scope => :user_id
  validates_uniqueness_of :command_id, :scope=>:user_id, :message=>'is already created for this user.'
  validates_uniqueness_of :name, :scope=>:user_id
  attr_protected :user_id
  serialize :url_options, Array
  
  named_scope :used, :conditions => ["user_commands.queries_count > 0"]
  named_scope :unused, :conditions => ["user_commands.queries_count = 0"]
  named_scope :popular, :conditions => ["user_commands.queries_count > 50"]
  named_scope :public, :conditions=>'commands.public = 1', :include=>:command
  named_scope :publicly_queriable, :conditions => {:public_queries => true}
  named_scope :quicksearches, :conditions => ["commands.kind ='parametric' AND commands.bookmarklet=0"], :include=>:command
  named_scope :bookmarklets, :conditions => ["commands.bookmarklet=1"], :include=>:command
  named_scope :shortcuts, :conditions => ["commands.kind ='shortcut' AND commands.bookmarklet=0"], :include=>:command
  named_scope :non_bootstrap, :conditions=>["commands.id NOT IN (1,2,3,4,5,6,7,8)"], :include=>:command
  named_scope :search, lambda {|v| {:conditions=>["user_commands.keyword REGEXP ? OR user_commands.url REGEXP ?", v, v]} }
  named_scope :any

  #fields which are passed from creating user_command to command on create + updates
  COMMAND_FIELDS = %w{url http_post url_encode public url_options}
  #fields which are passed from creating user_command to command on create
  COMMAND_CREATE_FIELDS = %w{name description origin keyword}
  COMMAND_ONLY_FIELDS = %w{public}
  
  def validate
    if self.keyword && COMMAND_STOPWORDS.include?(self.keyword.downcase)
      errors.add_to_base "Sorry, the keyword you've chosen (#{self.keyword}) is reserved by the system. Please use something else." 
    end
  end
  
  def before_validation_on_create
    self.keyword.downcase! if self.keyword
  end
  
  def initialize(*args)
    # p args[0]
    if args[0].is_a?(Hash)
      args[0].stringify_keys! #in case it's not an insensitive hash
      command_fields = COMMAND_FIELDS + COMMAND_CREATE_FIELDS
      command_hash = args[0].slice(*command_fields)
      args[0].except!(*COMMAND_ONLY_FIELDS)
    end
    super(*args)
    # p command_hash
    # p args[0]
    if self.command_id.nil? && self.command.nil?
      create_command_from_hash(command_hash) 
    else
      self.url = self.command.url
    end
    return self
  end
    
  def create_command_from_hash(command_hash)
    if command_hash
      #if desired command is public, look for existing command
      #nil in case public not specified
      if ['1', true, nil].include?(command_hash['public']) && (existing_command = Command.find_by_url_and_public(command_hash['url'], true))
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
  
  #used to update options from command url, for modified url in form and for auto-syncing
  def merge_url_options_with_options_in_url(url_value)
    latest_options = self.options_from_url(url_value)
    new_options = latest_options - self.options_from_url_options
    deleted_options = self.options_from_url_options - latest_options
    updated_url_options = self.url_options
    updated_url_options.delete_if {|e| deleted_options.include? e[:name]}
    new_options.each {|e| updated_url_options << {:name=>e} }
    updated_url_options
  end
  
  def update_all_attributes(hash, current_user)
    disabled_fields = get_disabled_update_fields(current_user)
    hash.except!(*disabled_fields)
    if update_attributes(hash.except(*COMMAND_ONLY_FIELDS))
      if self.command_owned_by?(current_user)
        command_fields = COMMAND_FIELDS
        command_fields += COMMAND_CREATE_FIELDS if current_user.is_admin?
        self.command.update_attributes_safely(hash.slice(*command_fields))
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
  
  def to_param; keyword; end
  
  def update_query_counts
    self.update_attribute(:queries_count, queries.count)
  end

  def public; new_record? ? true : command.public; end
  delegate :public?, :private?, :parametric?, :bookmarklet?, :to=>:command
  def public_queries?; self.public && self.public_queries; end
  
  def command_url_changed?
    self.command.url != self.url
  end
  
  def update_url_and_options
    new_url_options = self.merge_url_options_with_options_in_url(self.command.url)
    new_values = {:url=>self.command.url, :url_options=>new_url_options}
    self.update_attributes new_values
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