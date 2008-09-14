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
  def valid_user_attributes
    {
      :login => "bozo",
      :email => "bozo@email.com",
      :password  => "partyfavors",
      :password_confirmation  => "partyfavors"
    }
  end
  
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
    USER_STOPWORDS.should_not be_empty
    for word in USER_STOPWORDS
      # puts "Checking for invalidity of #{word}"
      @user.attributes = valid_user_attributes.with(:login => word)
      @user.should_not be_valid
    end
  end
  
  it "when destroyed also destroy related models except its commands" do
    user = create_user
    #create user commands, command and query for user
    setup_default_user_commands
    user.create_default_user_commands
    user.commands.create(:name=>'Bling', :url=>'bling.com', :keyword=>'bling')
    user.commands.size.should eql(1)
    query = create_query(:user_command=>user.user_commands[0])
    user.queries.size.should eql(1)
    
    query_command = query.user_command.command
    user_commands_size = user.user_commands.size
    lambda {
      lambda {
        lambda {
          lambda {
            lambda {
              user.destroy
            }.should change(User, :count).by(-1)
          }.should change(UserCommand, :count).by(user_commands_size * -1)
        }.should_not change(Command, :count)
      }.should change(Query, :count).by(-1)
    }.should change(query_command, :queries_count_all).by(-1)
    
    pending "confirm command is moved to public user"
  end
  
end

def setup_default_user_commands
  Command.destroy_all
  command_keywords = ["g", "gms", "w", "word", "q", "show", "edit", "new", "search"]
  test_commands = command_keywords.map {|e| create_command(:keyword=>e) }
  #override default command ids 
  User.class_eval %[
    @@test_commands = test_commands
    def default_commands_config
      @@test_commands.map {|e| {:command_id=>e.id} }
    end
  ]
end

describe "user with default commands:" do
  before(:all) do
    @user = create_user
    setup_default_user_commands
    @user.create_default_user_commands
  end
  
  it "create_default_user_commands() should generate some starter commands" do
    command_keywords = ["g", "gms", "w", "word", "q", "show", "edit", "new", "search"]
    @user.should have(9).user_commands
    @user.user_commands.map(&:keyword).sort.should == command_keywords.sort
  end
  
  it "should set default command" do
    @command = @user.user_commands.first
    @command.keyword.should eql("g")
    @user.default_command_id = @command.id
    @user.save!
    @user.default_command.keyword.should eql("g")
  end
    
end