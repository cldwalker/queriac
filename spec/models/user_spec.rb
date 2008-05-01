require File.dirname(__FILE__) + '/../spec_helper'
  
  # validates_presence_of     :login, :email
  # validates_presence_of     :password,                   :if => :password_required?
  # validates_presence_of     :password_confirmation,      :if => :password_required?
  # validates_length_of       :password, :within => 4..40, :if => :password_required?
  # validates_confirmation_of :password,                   :if => :password_required?
  # validates_format_of       :login,   :with => /[a-zA-Z0-9_]{1,16}/
  # validates_length_of       :email,    :within => 3..100
  # validates_uniqueness_of   :login, :email, :case_sensitive => false
  
describe User do
  
  before(:each) do
    @user = User.new
  end

  it "should be valid" do
    @user.attributes = valid_user_attributes
    @user.should be_valid
  end
  
  
  it "should not allow funky usernames"
  # it "should not allow funky usernames" do
  #   funky_logins = %w(this? !that #haxorz# bob.wtf)
  #   for login in funky_logins
  #     puts "Checking for invalidity of #{login}"
  #     @user.attributes = valid_user_attributes.with(:login => login)
  #     @user.should have(1).error_on(:login)
  #   end
  # end
  
  it "should prevent saving of commands with reserved stopwords" do
    STOPWORDS.should_not be_empty
    for word in STOPWORDS
      # puts "Checking for invalidity of #{word}"
      @user.attributes = valid_user_attributes.with(:login => word)
      @user.should_not be_valid
    end
  end
  
  it "should generate some starter commands" do
    @user.attributes = valid_user_attributes
    @user.save!
    @user.should have(8).commands
    @user.commands.map(&:keyword).join(" ").should eql("g gms w word q show edit new")
  end
  
  it "should set default command" do
    @user.attributes = valid_user_attributes
    @user.save!
    @command = @user.commands.first
    @command.keyword.should eql("g")
    @user.default_command_id = @command.id
    @user.save!
    @user.default_command.keyword.should eql("g")
  end
    
end