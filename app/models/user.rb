# == Schema Information
# Schema version: 14
#
# Table name: users
#
#  id                        :integer(11)     not null, primary key
#  login                     :string(255)     
#  email                     :string(255)     
#  crypted_password          :string(40)      
#  salt                      :string(40)      
#  created_at                :datetime        
#  updated_at                :datetime        
#  remember_token            :string(255)     
#  remember_token_expires_at :datetime        
#  activation_code           :string(40)      
#  activated_at              :datetime        
#  default_command_id        :integer(11)     
#  first_name                :string(255)     
#  last_name                 :string(255)     
#  per_page                  :integer(11)     
#

require 'digest/sha1'
class User < ActiveRecord::Base
  has_many :commands, :dependent => :destroy
  has_many :queries
  has_many :tags, :through => :commands
  
  belongs_to :default_command, :class_name => "Command", :foreign_key => :default_command_id
  
  # Why do these break shit?
  # has_finder :activated, :conditions => ["activation_code IS NOT NULL"]
  # has_finder :any
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_format_of       :login,   :with => /[a-zA-Z0-9_]{1,16}/
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password
  before_create :make_activation_code 
  
  def validate
    if STOPWORDS.include?(self.login.downcase)
      errors.add_to_base "Sorry, the username you've chosen (#{self.login}) is reserved by the system. Please use something else."
    end
  end
  
  def after_create
    g = self.commands.create!(
      :name => "Google Quicksearch", 
      :keyword => "g",
      :url => "http://www.google.com/search?q=(q)",
      :description => "Performs a basic Google search."
    )
    g.update_tags("google") 
    
    gms = self.commands.create!(
      :name => "Gmail Search", 
      :keyword => "gms",
      :url => "http://mail.google.com/mail/?search=query&view=tl&start=0&init=1&fs=1&q=(q)",
      :description => "Search your Gmail. If you're not logged in you'll be directed to the Gmail login page.\n\nExamples\ngms dog\ngms is:starred mom\ngms label:todo"
    )
    gms.update_tags("google gmail mail")
  
    w = self.commands.create!(
      :name => "Google \"I'm Feeling Lucky\" Wikipedia (en) search",
      :keyword => "w",
      :url => "http://www.google.com/search?btnI=I'm%20Feeling%20Lucky&q=site:en.wikipedia.org%20(q)",
      :description => "Jumps to Google's first search result for the query you've entered + site:en.wikipedia.org\n\nExample: w colonel sanders"
    )
    w.update_tags("google wikipedia")
    
    word = self.commands.create!(
      :name => "Dictionary Lookup at Reference.com",
      :keyword => "word",
      :url => "http://www.reference.com/browse/all/(q)",
      :description => "Look up word definitions\n\nExample: word peripatetic"
    )
    word.update_tags("dictionary reference language english")
    
    q = self.commands.create!(
      :name => "My Queriac Page",
      :keyword => "q",
      :url => "http://queri.ac/#{self.login}/",
      :description => "A shortcut to my queriac account page."
    )
    q.update_tags("queriac bootstrap")
    
    show = self.commands.create!(
      :name => "Show a Queriac command",
      :keyword => "show",
      :url => "http://queri.ac/#{self.login}/(q)/show",
      :description => "Show info on a queriac command.\n\nExample: show g"
    )
    show.update_tags("queriac bootstrap")
    
    edit = self.commands.create!(
      :name => "Edit a Queriac command",
      :keyword => "edit",
      :url => "http://queri.ac/#{self.login}/(q)/edit",
      :description => "Edit a queriac command.\n\nExample: edit g"
    )
    edit.update_tags("queriac bootstrap")
    
    n = self.commands.create!(
      :name => "Create a new Queriac command",
      :keyword => "new",
      :url => "http://queri.ac/commands/new",
      :description => "Shortcut to the queriac page for creating a new account."
    )
    n.update_tags("queriac bootstrap")
  
  end
  
  def home_path
    "/#{login}/"
  end
  
  def opensearch_path
    "/#{login}/opensearch/"
  end

  def commands_path
    "/#{login}/commands/"
  end
  
  def commands_tag_path(tag)
    "/#{login}/commands/tag/#{tag}"
  end
  
  def queries_path
    "/#{login}/queries/"
  end
  
  def queries_tag_path(tag)
    "/#{login}/queries/tag/#{tag}"
  end
  
  def default_command_path(query)
    "/#{login}/default_to #{default_command.keyword} #{query}"
  end
  
  def default_command?
    return false if default_command_id.nil?
    return false if default_command.nil?
    true
  end
  
  # Remaining public methods generated by restul_authentication
  #------------------------------------------------------------------------------------------------------------------
  
  # Activates the user in the database.
  def activate
    @activated = true
    self.attributes = {:activated_at => Time.now.utc, :activation_code => nil}
    save(false)
  end

  def activated?
    activation_code.nil?
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? OR email = ?', login, login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 1.year
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end

    
    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end 
end
