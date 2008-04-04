require File.dirname(__FILE__) + '/../spec_helper'


#common examples
def should_redirect_nonexistent_user(action)
  it "nonexistent user" do
    get action, :login=>'invalid_login', :command=>'valid'
    response.should be_redirect
    flash[:warning].should_not be_nil
  end
end

def should_redirect_nonexistent_command(action)
  it "nonexistent command" do
    get action, :login=>@user.login, :command=>'bling'
    response.should be_redirect
    assigns[:command].should be_nil
    flash[:warning].include?('has no command').should be_true
  end
end

def should_redirect_prohibited_action(action)
  it "accessing a prohibited action" do
    get action, :login=>create_user.login, :command=>'some_command'
    response.should be_redirect
    flash[:warning].should match(/not allowed/)
  end
end

describe 'commands/*:' do
  controller_name :commands
  integrate_views
  
  it 'update examples'
  it 'index examples'
  it 'create examples'
  it 'execute examples'
end

describe 'commands/show (default as anonymous user):' do
  controller_name :commands
  integrate_views
  
  before(:all) { @user = create_user }  
  after(:each) { @user.commands.each {|e| e.destroy} }
  
  def basic_expectations
    response.should be_success
    assigns[:user].should_not be_nil
    assigns[:command].should be_an_instance_of(Command)
  end
  
  it "basic" do
    command = @user.commands.create(random_valid_command_attributes)
    command.queries.create(:user_id=>@user.id, :query_string=>'blah')
    get 'show', :login=>@user.login, :command=>command.keyword
    basic_expectations
    assigns[:queries][0].should be_an_instance_of(Query)
  end
  
  should_redirect_nonexistent_command('show')
  
  should_redirect_nonexistent_user('show')
  
  it "private queries" do
    command = @user.commands.create(random_valid_command_attributes.merge(:public_queries=>false))
    command.queries.create(:user_id=>@user.id, :query_string=>'blah')
    get 'show', :login=>@user.login, :command=>command.keyword
    basic_expectations
    pending("handle querying for private queries correctly")
    assigns[:queries].should be_nil
  end
  
  it "private command" do
    command = @user.commands.create(random_valid_command_attributes.merge(:public=>false))
    command.queries.create(:user_id=>@user.id, :query_string=>'blah')
    get 'show', :login=>@user.login, :command=>command.keyword
    response.should be_redirect
    flash[:warning].should_not be_nil
  end
  
  it "as logged-in user viewing own command"
  it "as logged-in user viewing someone else's command"
end

describe 'commands/new:' do
  controller_name :commands
  integrate_views
  
  #using before(:all) to minimize db calls (speed up tests) until objects can be mocked
  #coupling examples to the same test object is a no-no: http://rspec.info/documentation/before_and_after.html
  before(:all) do
    @user = create_user
    @command_hash = random_valid_command_attributes.dup.merge(:description=>'coolness')
  end
  before(:each) { login_user(@user)}
  
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
  controller_name :commands
  integrate_views
  
  before(:all) { @user = create_user }
  before(:each) { login_user(@user)}
  after(:each) { @user.commands.each {|e| e.destroy} }  
  
  it 'basic' do
    command = current_user.commands.create(random_valid_command_attributes)
    get 'edit', :login=>current_user.login, :command=>command.keyword
    response.should be_success
    response.should render_template('edit')
    assigns[:command].should be_an_instance_of(Command)
  end
  
  should_redirect_nonexistent_user('edit')
  should_redirect_nonexistent_command('edit')
  should_redirect_prohibited_action('edit')
end

#TODO: update get to delete when update is done in code
describe 'commands/destroy:' do
  controller_name :commands
  integrate_views
  
  before(:all) { @user = create_user}
  before(:each) { login_user(@user)}
  
  it 'basic' do
    command = current_user.commands.create(random_valid_command_attributes)
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

