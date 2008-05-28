class TempCommand < ActiveRecord::Base
  belongs_to :user
  #has_many :queries, :dependent => :destroy
  has_many :queries, :through=>:user_commands
  has_many :temp_queries, :through=>:user_commands
  
  #acts_as_taggable
  has_many :user_commands, :dependent=>:destroy, :foreign_key=>'command_id'
  has_many :users, :through=>:user_commands
  has_many :user_tags, :through=>:user_commands
  
  # has_finder :used, :conditions => ["commands.queries_count_all > 0"]
  # has_finder :unused, :conditions => ["commands.queries_count_all = 0"]
  # has_finder :popular, :conditions => ["commands.queries_count_all > 50"]
  has_finder :public, :conditions => {:public => true}
  # has_finder :publicly_queriable, :conditions => {:public_queries => true}
  # has_finder :quicksearches, :conditions => {:kind => "parametric", :bookmarklet => false}
  # has_finder :bookmarklets, :conditions => {:bookmarklet => true}
  # has_finder :shortcuts, :conditions => {:kind => "shortcut", :bookmarklet => false}
  has_finder :any
  
  validates_presence_of :name, :url
  # validates_format_of :keyword, :with => /^\w+$/i, :message => "can only contain letters and numbers."
  
  #validates_uniqueness_of :url, :scope=>[:http_post, :url_encode, :public] unless Proc.new {|c| c.private?}
  validates_uniqueness_of :url, :scope=>[:public] unless Proc.new {|c| c.private? } #CHANGED for tests
  #validates_uniqueness_of :url, :scope=>[:public] if Proc.new {|c| c.public? } #worked for public_commands
  validates_uniqueness_of :keyword, :allow_nil=>true
  # validates_uniqueness_of :keyword, :scope => :user_id
  # validates_uniqueness_of :url, :scope => :user_id
  
  # Validation / Initialization
  #------------------------------------------------------------------------------------------------------------------

  def validate
    if self.keyword && STOPWORDS.include?(self.keyword.downcase)
      errors.add_to_base "Sorry, the keyword you've chosen (#{self.keyword}) is reserved by the system. Please use something else." 
    end
  end
  
  def after_validation_on_create
    if self.errors['keyword'] && self.errors['keyword'].include?('has already')
      self.keyword = nil
      self.errors.instance_eval "@errors.delete('keyword')"
      self.save if self.valid?
    end
  end
  
  def after_validation
    self.keyword.downcase! if self.keyword
    self.url.sub!('%s', DEFAULT_PARAM )
    self.kind = self.url.include?(DEFAULT_PARAM) ? "parametric" : "shortcut"
    self.bookmarklet = self.url.downcase.starts_with?('javascript') ? true : false
  end
  
  # def url=(url)
  #   super(url.blank? || url.downcase.starts_with?('http') || url.downcase.starts_with?('file') || url.downcase.starts_with?('javascript') ? url : "http://#{url}")
  # end

  # Booleans
  #------------------------------------------------------------------------------------------------------------------
  def parametric?; self.kind == "parametric"; end
  def private?; !public?; end
  def public_queries?; self.public && self.public_queries; end
  
  # Miscellany
  #------------------------------------------------------------------------------------------------------------------
  # def save_query(query_string)
  #   self.queries.create(:query_string => query_string)
  # end
  
  def created_by?(possible_owner)
    self.user == possible_owner
  end
  
  def creator_command
    self.user_commands.find(:first, :conditions=>{:user_id=>self.user_id})
  end
  
  def url_for(query_string, manual_url_encode=nil)
    is_url_encoded = !manual_url_encode.nil? ? manual_url_encode : url_encode?
    if is_url_encoded
      self.url.gsub(DEFAULT_PARAM, CGI.escape(query_string))
    else
      self.url.gsub(DEFAULT_PARAM,query_string)
    end
  end
  
  def domain
    # Found the regex at http://yubnub.org/kernel/man?args=extractdomainname
    u = url
    if bookmarklet?
      return nil if url.split("http").size == 1
      u = "http" + url.split("http").last
    end
    u=~(/^(?:\w+:\/\/)?([^\/?]+)(?:\/|\?|$)/) ? $1 : nil
  end
  
  def favicon_url
    return "/images/icons/blank_bordered.png" if domain.nil?
    "http://#{domain}/favicon.ico"
  end
  
  def update_tags(tags)
    self.tag_list = tags.split(" ").join(", ")
    self.save
  end
  
  def tag_string
    self.tag_list.join(" ")
  end
  
  # def update_query_counts
  #   self.update_attribute(:queries_count_all, queries.count)
  #   self.update_attribute(:queries_count_owner, queries.count(:conditions => ["queries.user_id = ?", self.user.id]))
  # end
  
  # def queries_count_outsiders
  #   queries_count_all - queries_count_owner
  # end
  
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
  
end
