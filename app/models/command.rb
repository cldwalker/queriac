# == Schema Information
# Schema version: 10
#
# Table name: commands
#
#  id             :integer(11)     not null, primary key
#  name           :string(255)     
#  keyword        :string(255)     
#  url            :text            
#  description    :text            
#  kind           :string(255)     
#  origin         :string(255)     default("hand")
#  created_at     :datetime        
#  modified_at    :datetime        
#  bookmarklet    :boolean(1)      
#  user_id        :integer(11)     
#  public         :boolean(1)      default(TRUE)
#  public_queries :boolean(1)      default(TRUE)
#

class Command < ActiveRecord::Base
  belongs_to :user
  has_many :queries, :dependent => :destroy

  validates_presence_of :name, :keyword, :url
  validates_format_of :keyword, :with => /(?=.*([a-z]|[A-Z]))/, :message => "must contain at least one letter."  
  validates_uniqueness_of :keyword, :scope => :user_id
  validates_uniqueness_of :url, :scope => :user_id
  
  # Validation / Initialization
  #------------------------------------------------------------------------------------------------------------------

  def validate
    stopwords = %w(new view edit delete tags tag help home setup)
    if stopwords.include?(self.keyword.downcase)      
      errors.add_to_base "Sorry, the keyword you've chosen (#{self.keyword}) is reserved by the system. Please use something else" 
    end
  end
  
  def after_validation
    self.keyword.downcase!
    self.url.sub!('%s', DEFAULT_PARAM )
    self.kind = self.url.include?(DEFAULT_PARAM) ? "parametric" : "shortcut"
    self.bookmarklet = self.url.downcase.starts_with?('javascript') ? true : false
  end
  
  def url=(url)
    super(url.blank? || url.downcase.starts_with?('http') || url.downcase.starts_with?('file') || url.downcase.starts_with?('javascript') ? url : "http://#{url}")
  end

  # Booleans
  #------------------------------------------------------------------------------------------------------------------
  def parametric?; self.kind == "parametric"; end
  def bookmarklet?; self.bookmarklet; end
  
  # Paths
  #------------------------------------------------------------------------------------------------------------------
  def view_path
    "/#{self.user.login}/#{self.keyword}/view"
  end
  
  def edit_path
    "/#{self.user.login}/#{self.keyword}/edit"
  end
  
  def delete_path
    "/#{self.user.login}/#{self.keyword}/delete"
  end
  
  # Finds
  #------------------------------------------------------------------------------------------------------------------
  def self.find_public(*args)
    with_scope(:find => {:conditions => {:public => true}}) do
      self.find(*args)
    end
  end
   
  # Miscellany
  #------------------------------------------------------------------------------------------------------------------
  def save_query(query_string)
    self.queries.create(:query_string => query_string)
  end
  
  def url_for(query_string)
    self.url.sub(DEFAULT_PARAM, CGI.escape(query_string))
  end
  
  
end
