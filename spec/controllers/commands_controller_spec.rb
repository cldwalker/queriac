require File.dirname(__FILE__) + '/../spec_helper'

module CommandsControllerHelper
  
  #using before(:all) to minimize db calls (speed up tests) until objects can be mocked
  #coupling examples to the same test object is a no-no: http://rspec.info/documentation/before_and_after.html
  def setup_login_user
    before(:all) { @user = create_user }
    before(:each) { login_user(@user)}
  end

  #common examples
  def should_redirect_nonexistent_user(action)
    it "redirect nonexistent user" do
      get action, :login=>'invalid_login', :command=>'valid'
      response.should be_redirect
      flash[:warning].should_not be_nil
    end
  end

  def should_redirect_nonexistent_command(action)
    it "redirect nonexistent command" do
      get action, :login=>@user.login, :command=>'bling'
      response.should be_redirect
      assigns[:command].should be_nil
      flash[:warning].include?('has no command').should be_true
    end
  end

  def should_redirect_prohibited_action(action)
    it "redirect a prohibited action" do
      get action, :login=>create_user.login, :command=>'some_command'
      response.should be_redirect
      flash[:warning].should match(/not allowed/)
    end
  end

end

def setup_commands_controller_example_group
  controller_name :commands
  integrate_views
  extend CommandsControllerHelper
end

describe 'commands/index:' do
  setup_commands_controller_example_group
  before(:all) { @command = create_command }
  
  def basic_expectations
    response.should be_success
    response.should render_template('index')
    assigns[:commands][0].should be_an_instance_of(Command)
  end
  
  it 'all w/o tags' do
    Command.should_receive(:public).and_return([@command])
    get :index
    basic_expectations
  end
  
  it 'all w/ tags'
  
  it 'user w/o tags' do
    get :index, :login=>@command.user.login
    basic_expectations
  end
  
  it 'user w/ tags'
  it 'basic w/ invalid tags'
  
  it 'redirects when no commands are found' do
    Command.should_receive(:public).and_return([])
    get :index
    response.should be_redirect
    flash[:warning].should_not be_blank
    assigns[:commands].should be_empty
  end
end

describe 'commands/execute:' do
  controller_name :commands
  integrate_views
  
  it 'basic w/o args'
  it 'basic w/ args'
  it 'default_to query'
  it 'nil command w/ default command'
  it 'nil command w/o default command'
  it 'private command'
  it 'stealth query starting w/ !'
  it 'stealth query w/ separate !'
  it 'bookmarklet'
end

describe 'commands/show (default as anonymous user):' do
  setup_commands_controller_example_group
  
  before(:all) { @user = create_user }  
  after(:each) { @user.commands.each {|e| e.destroy} }
  
  def basic_expectations
    response.should be_success
    assigns[:user].should_not be_nil
    assigns[:command].should be_an_instance_of(Command)
  end
  
  it "basic" do
    command = create_command(:user=>@user)
    command.queries.create(:user_id=>@user.id, :query_string=>'blah')
    get 'show', :login=>@user.login, :command=>command.keyword
    basic_expectations
    assigns[:queries][0].should be_an_instance_of(Query)
  end
  
  should_redirect_nonexistent_command('show')
  
  should_redirect_nonexistent_user('show')
  
  it "private queries" do
    command = create_command(:user=>@user, :public_queries=>false)
    command.queries.create(:user_id=>@user.id, :query_string=>'blah')
    get 'show', :login=>@user.login, :command=>command.keyword
    basic_expectations
    pending("handle querying for private queries correctly")
    assigns[:queries].should be_nil
  end
  
  it "private command" do
    command = create_command(:user=>@user, :public=>false)
    command.queries.create(:user_id=>@user.id, :query_string=>'blah')
    get 'show', :login=>@user.login, :command=>command.keyword
    response.should be_redirect
    flash[:warning].should_not be_nil
  end
  
  it "as logged-in user viewing own command"
  it "as logged-in user viewing someone else's command"
end

describe 'commands/new:' do
  setup_commands_controller_example_group
  
  setup_login_user
  before(:all) { @command_hash = random_valid_command_attributes.dup.merge(:description=>'coolness') }
  
  it "basic" do
    get 'new'
    basic_expectations
  end
  
  def basic_expectations
    response.should be_success
    response.should render_template(:new)
    assigns[:command].should be_an_instance_of(Command)
  end
  
  def all_expectations
    basic_expectations
    #ensure command is populated with values from params or ancestor
    assigns[:command].attributes.symbolize_keys.only(*@command_hash.keys).values.sort.should eql(@command_hash.values.sort)
  end
  
  it "prepopulation" do
    get 'new', @command_hash.dup
    all_expectations
  end
  
  it "public ancestor" do
    ancestor = stub('ancestor', @command_hash.merge(:'public?'=>true, :tag_string=>''))
    Command.should_receive(:find).and_return(ancestor)
    get 'new', :ancestor=>'mock_id'
    all_expectations
  end
  
  it "your own private ancestor" do
    ancestor = stub('ancestor', @command_hash.merge(:'public?'=>false, :tag_string=>'', :user=>current_user))
    Command.should_receive(:find).and_return(ancestor)
    get 'new', :ancestor=>'mock_id'
    all_expectations
  end
  
  it "someone else's private ancestor" do
    ancestor = stub('ancestor', @command_hash.merge(:'public?'=>false, :tag_string=>'', :user=>mock('not_current_user')))
    Command.should_receive(:find).and_return(ancestor)
    get 'new', :ancestor=>'mock_id'
    response.should be_redirect
    flash[:warning].should_not be_nil
  end
end

describe 'commands/edit:' do
  setup_commands_controller_example_group
  
  setup_login_user
  after(:each) { @user.commands.each {|e| e.destroy} }  
  
  it 'basic' do
    command = create_command(:user=>current_user)
    get 'edit', :login=>current_user.login, :command=>command.keyword
    response.should be_success
    response.should render_template('edit')
    assigns[:command].should be_an_instance_of(Command)
  end
  
  should_redirect_nonexistent_user('edit')
  should_redirect_nonexistent_command('edit')
  should_redirect_prohibited_action('edit')
end

describe 'commands/create:' do
  setup_commands_controller_example_group
  
  setup_login_user
  def post_request
    post :create, :command=>random_valid_command_attributes.merge(:description=>"cool"), :tags=>''
  end
  
  it 'basic' do
    lambda { post_request }.should change(Command, :count).by(1)
    response.should be_redirect
    flash[:notice].should_not be_blank
    assigns[:command].should be_an_instance_of(Command)
    assigns[:command].user.should == @user
  end
  
  it 'failed create displays new again' do
    command = Command.new
    command.stub!(:save).and_return(false)
    Command.should_receive(:new).and_return(command)
    lambda { post_request}.should_not change(Command, :count)
    response.should be_success
    assigns[:command].should be_an_instance_of(Command)
    response.should render_template(:new)
  end
  
  it 'w/ bookmarks file' do
    mock_file = stub('file', :read=>"bookmark info", :'blank?'=>false)
    Command.should_receive(:create_commands_for_user_from_bookmark_file).with(@user, anything).and_return([1,2])
    post :create, :bookmarks_file=>mock_file
    response.should be_redirect
    flash[:notice].should_not be_blank
  end
  
  it 'w/ invalid bookmarks file' do
    post :create, :bookmarks_file=>''
    response.should be_success
    response.should render_template(:new)
    assigns[:command].should be_an_instance_of(Command)
    flash[:warning].should_not be_blank
  end
end

describe 'commands/update:' do
  setup_commands_controller_example_group
  
  setup_login_user
  after(:each) { @user.commands.each {|e| e.destroy} }  
    
  it 'basic' do
    command = create_command(:user=>@user)
    put :update, :id=>command.id, :command=>{:name=>'another name'}, :tags=>''
    command.reload.name.should eql('another name')
    response.should be_redirect
    flash[:notice].should_not be_nil
  end
  
  it "redirect a prohibited action" do
    command = create_command
    put :update, :id=>command.id, :command=>{:name=>'another name'}, :tags=>''    
    response.should be_redirect
    flash[:warning].should match(/not allowed/)
  end
  
  it 'failed update displays edit again' do
    command = create_command(:user=>@user)
    command.stub!(:update_attributes).and_return(false)
    Command.should_receive(:find).and_return(command)
    put :update, :id=>command.id, :command=>{:name=>'another name'}, :tags=>''
    response.should be_success
    response.should render_template('edit')
  end
  
  it 'raises error for invalid command id' do
    lambda {
      put :update, :id=>'some id', :command=>{:name=>'another name'}, :tags=>''
    }.should raise_error(ActiveRecord::RecordNotFound)
  end
end

#TODO: update get to delete when update is done in code
describe 'commands/destroy:' do
  setup_commands_controller_example_group
  
  setup_login_user
  
  it 'basic' do
    command = create_command(:user=>current_user)
    lambda {
      get 'destroy', :login=>current_user.login, :command=>command.keyword
    }.should change(Command, :count).by(-1)
    response.should be_redirect
    flash[:notice].should_not be_nil
  end
  
  should_redirect_nonexistent_user('destroy')
  should_redirect_nonexistent_command('destroy')
  should_redirect_prohibited_action('destroy')
end

