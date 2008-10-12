class Command < ActiveRecord::Base
  include CommandHelper
  belongs_to :user
  has_many :queries, :through=>:user_commands
  has_many :user_commands, :dependent=>:destroy
  has_many :users, :through=>:user_commands, :conditions=>User::VIEWABLE_SQL
  has_many :user_tags, :through=>:user_commands, :source=>:tags
  
  acts_as_cached
  acts_as_taggable
  named_scope :public, :conditions => {:public => true}
  named_scope :any
  named_scope :unique, :select=>'*, count(url)', :group=>"url HAVING count(url)>=1"
  named_scope :search, lambda {|v| {:conditions=>["commands.keyword REGEXP ? OR commands.url REGEXP ?", v, v]} }
  named_scope :advanced_search, lambda {|v| parse_advanced_search(v) }
  named_scope :options, :conditions=>"commands.url_options IS NOT NULL"
  named_scope :bookmarklets, :conditions => ["commands.bookmarklet=1"]
  named_scope :nonshortcuts, :conditions=>["NOT(commands.kind ='shortcut' AND commands.bookmarklet=0)"]
  named_scope :shortcuts, :conditions => ["commands.kind ='shortcut' AND commands.bookmarklet=0"]
  named_scope :quicksearches, :conditions => ["commands.kind ='parametric' AND commands.bookmarklet=0"]
  
  after_update :expire_cache
  before_update :update_revised_at, :destroy_public_user_command_if_privatized
  validates_presence_of :name, :url
  validates_uniqueness_of :name
  validates_uniqueness_of :url, :scope=>[:public], :unless=>Proc.new {|c| c.private? }
  validates_uniqueness_of :keyword, :allow_nil=>true
  validates_format_of :keyword, :with => /^\w+$/i, :message => "can only contain letters and numbers.", :unless=>Proc.new {|c| c.keyword.nil?}  
  serialize :url_options, Array
  
  TYPES = [:bookmarklets, :shortcuts, :options, :quicksearches]
  
  def to_param; self.keyword || self.id; end
  
  # Validation / Initialization
  #------------------------------------------------------------------------------------------------------------------
  
  def validate
    if self.keyword
      if COMMAND_STOPWORDS.include?(self.keyword.downcase)
        errors.add_to_base "Sorry, the keyword you've chosen (#{self.keyword}) is reserved by the system. Please use something else." 
      #to prevent uniqueness clash since keyword + id are used interchangeably as a unique public id
      elsif self.keyword =~ /^\d+$/
        errors.add(:keyword, "can't only contain numbers.")
      end
    end
    validate_url_options if has_options? 
  end
  
  #trying to ensure commands are created from user command creation even
  #when commands are initially invalid
  def after_validation_on_create
    if self.errors['keyword'] && self.errors['keyword'].include?('has already')
      self.keyword = nil
      self.errors.instance_eval "@errors.delete('keyword')"
      self.save if self.valid?
    end
    if self.errors['name'] && self.errors['name'].include?('has already')
      self.name = "#{self.name} version #{rand(10000)}"
      self.errors.instance_eval "@errors.delete('name')"
      self.save if self.valid?
    end
  end
  
  def before_validation_on_create
    self.keyword.downcase! if self.keyword
    self.url.sub!('%s', DEFAULT_PARAM )
  end
  
  def after_validation
    self.kind = (self.url.include?(DEFAULT_PARAM) || self.url =~ OPTION_PARAM_REGEX) ? "parametric" : "shortcut"
    self.bookmarklet = url_is_bookmarklet?(self.url)
  end
  
  #Callback methods
  #------------------------------------------------------------------------------------------------------------------
  
  def expire_cache
    self.expire_cached(:show_page)
    true
  end
  
  def destroy_public_user_command_if_privatized
    if self.changed.include?('public') && self.public == false
      (user_command = self.user_commands.detect {|e| e.user.login == User::PUBLIC_USER}) && user_command.destroy
    end
    true
  end
  
  def update_revised_at
    self.revised_at = Time.now if self.changed.include?('url')
    true
  end
  
  # Booleans
  #------------------------------------------------------------------------------------------------------------------
  def parametric?; self.kind == "parametric"; end
  def private?; !public?; end
  
  # Miscellany
  #------------------------------------------------------------------------------------------------------------------
  
  #to be called from vicarious updates ie @user_command.update_all_attributes
  def update_attributes_safely(*args)
    self.update_attributes(*args)
    if self.errors['keyword'] && self.errors['keyword'].include?('has already')
      self.errors.instance_eval "@errors.delete('keyword')"
      self.keyword = self.keyword_was
      self.save if self.valid?
    end
  end
  
  def created_by?(possible_owner)
    self.user == possible_owner
  end
  
  def creator_command
    self.user_commands.find(:first, :conditions=>{:user_id=>self.user_id})
  end
  
  def increment_users_count(increment_count=1)
    self.update_attribute(:users_count, self.users_count + increment_count)
  end
  
  def increment_query_count(increment_count=1)
    self.update_attribute(:queries_count_all, self.queries_count_all + increment_count)
  end
  
  def decrement_user_command_counts(queries_count=1)
    hash = {}
    if self.queries_count_all > 0
      hash[:queries_count_all] = self.queries_count_all - queries_count
    end
    hash[:users_count] = self.users_count - 1
    self.update_attributes hash
  end
  
  def self.parse_advanced_search(query)
    allowed_columns = %w{name description url keyword}
    if query[/-[^c]/]
      query_array = query.split(/\s*-\s*/).map {|e| e.split(/\s+/) }.flatten
      query_hash = Hash[*query_array]
      query_hash.each {|k,v| 
        if (col = allowed_columns.find {|e| e.starts_with?(k)})
          query_hash.delete(k)
          query_hash[col] = v
        end
      }
    else
      if query[/-c/]
        option, columns, query = query.split(/\s+/, 3)
        query_columns = columns.split(/\s*,\s*/).map {|e| allowed_columns.find {|f| f.starts_with?(e)}}.compact
      else
        query_columns = ['url', 'keyword']
      end
        
      query_array = query_columns.zip(Array.new(query_columns.size, query)).flatten
      query_hash = Hash[*query_array]
    end
    query_hash.delete_if {|k,v| !allowed_columns.include?(k)}
    query_string = query_hash.keys.map {|k| "commands.#{k} REGEXP :#{k}"}.join(" OR ")
    {:conditions=>[query_string, query_hash.symbolize_keys] }
  end
  
  def self.create_commands_for_user_from_bookmark_file(user, file)
    valid_commands = []
    invalid_commands = []
    doc = open(file) { |f| Hpricot(f) }
    (doc/"a").each do |a|
      unless a.attributes['shortcuturl'].blank?
        name = a.inner_html
        keyword = a.attributes['shortcuturl']
        url = a.attributes['href']
        command = user.user_commands.create(:name => name, :keyword => keyword,
          :url => url, :origin => "import")
        if command.valid?
          valid_commands << command
        else
          invalid_commands << command
        end
      end
    end
    invalid_commands.each {|c|
      logger.error "INVALID_COMMAND: " + c.inspect
      logger.error c.errors.full_messages.join(', ')
    } 
    return [valid_commands, invalid_commands]
  end
  
  def self.find_by_keyword_or_id(id, options={})
    find(:first, {:conditions=>["commands.keyword = ? OR commands.id = ?", id, id]}.merge(options))
  end
  
  def self.parse_into_keyword_and_query(command_string)
    options = {:defaulted=>false, :toggle_save_query=>false}
    
    # Note: When upgrading to Rails 2, split(' ') had to be changed into split('+')
    param_parts = command_string.gsub(' ', '+').split('+')
    
    ##Parsing Starts
    keyword = (param_parts.shift || '').downcase
    
    if keyword == "default_to"
      keyword = (param_parts.shift || '').downcase 
      options[:defaulted] = true
    end
    
    # Handle stealth queries (allowing for presence or absence of space following the !)
    if keyword.starts_with? "!"
      options[:toggle_save_query] = true
      if keyword == "!"
        keyword = (param_parts.shift || '').downcase
      else
        keyword = keyword.slice(1, keyword.length-1)
      end
    end
    
    query_string = param_parts.join(' ') 
    
    return keyword, query_string, options
  end
  
  JAVASCRIPT_SYMBOLS = {":url"=>":u", ":host"=>":h", ":fullhost"=>":H", ":selection"=>":s", ":title"=>":t"}
  def self.convert_to_javascript(query)
    prefix_string = "javascript:var new_location="
    query = CGI::unescape(query)
    js_result = query.gsub(/(.*?)(#{JAVASCRIPT_SYMBOLS.keys.join('|')})/) do
      js_term = case $2
      when ':url'
        "encodeURIComponent(location.href)"
      when ':host'
        "encodeURIComponent(location.host)"
      when ':fullhost'
        "encodeURIComponent(location.protocol + '//') + encodeURIComponent(location.host)"
      when ':selection'
        "encodeURIComponent(window.getSelection())"
      when ':title'
        "encodeURIComponent(document.title)"
      end
      #NOTE: may need to escape() $1 for commands with quotes such as lucky and commands that need encoding
      #results with '"' won't work
      %["#{$1}"+#{js_term}+]
    end
    js_result = '"' + query + '"' if js_result == query
    result = prefix_string + js_result.gsub(/\+\s*$/,'').gsub(/\s*"$/,'"')
    result += ";window.location=new_location"
    result
  end
  
  def show_page
    user_commands = self.user_commands.find(:all, :limit=>5, :order=>'queries_count DESC', :include=>:user)
    queries = self.queries.public.find(:all, :order => "queries.created_at DESC", :limit=>30)
    [user_commands, queries]
  end
  
end
