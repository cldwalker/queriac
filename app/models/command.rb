class Command < ActiveRecord::Base
  include CommandHelper
  belongs_to :user
  has_many :queries, :through=>:user_commands, :order=>'queries.created_at DESC'
  has_many :user_commands, :dependent=>:destroy
  has_many :users, :through=>:user_commands, :conditions=>User::VIEWABLE_SQL
  has_many :user_tags, :through=>:user_commands
  
  has_finder :public, :conditions => {:public => true}
  has_finder :any
  
  validates_presence_of :name, :url
  validates_uniqueness_of :name
  validates_uniqueness_of :url, :scope=>[:public], :unless=>Proc.new {|c| c.private? }
  validates_uniqueness_of :keyword, :allow_nil=>true
  validates_format_of :keyword, :with => /^\w+$/i, :message => "can only contain letters and numbers.", :unless=>Proc.new {|c| c.keyword.nil?}  
  
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
      false
    end
    true
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
  
  def after_validation
    self.keyword.downcase! if self.keyword
    self.url.sub!('%s', DEFAULT_PARAM )
    self.kind = self.url.include?(DEFAULT_PARAM) ? "parametric" : "shortcut"
    self.bookmarklet = self.url.downcase.starts_with?('javascript') ? true : false
  end
  
  def to_param; self.keyword || self.id; end
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
  
  # def update_tags(tags)
  #   self.tag_list = tags.split(" ").join(", ")
  #   self.save
  # end
  # 
  # def tag_string
  #   self.tag_list.join(" ")
  # end
  
  def update_query_counts
    self.update_attribute(:queries_count_all, self.queries_count_all + 1)
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
end
