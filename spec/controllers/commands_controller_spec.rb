require File.dirname(__FILE__) + '/../spec_helper'

module CommandsControllerHelper
  #common examples
  def should_redirect_nonexistent_user(action)
    it "redirect nonexistent user" do
      get action, :login=>'invalid_login', :command=>'valid'
      response.should be_redirect
      flash[:warning].should_not be_blank
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
  before(:all) { @command = create_command; @tag = create_tag }
  
  def basic_expectations
    response.should be_success
    assigns[:commands][0].should be_an_instance_of(Command)
  end
  
  it 'all w/o tags' do
    Command.should_receive(:public).and_return([@command])
    get :index
    basic_expectations
  end
  
  it 'all w/ tags' do
    @command.tags << @tag
    get :index, :tag=>[@tag.name]
    basic_expectations
    assigns[:tags].should_not be_empty
    @command.tags.clear
  end
  
  it 'all w/ more than one tag'
  it "publicity of user's own command vs another's command"
  
  it 'user w/o tags' do
    get :index, :login=>@command.user.login
    basic_expectations
    assigns[:user].should be_an_instance_of(User)
  end
  
  it 'user w/ tags' do
    @command.tags << @tag
    get :index, :login=>@command.user.login, :tag=>[@tag.name]
    basic_expectations
    assigns[:tags].should_not be_empty
    assigns[:user].should be_an_instance_of(User)
    @command.tags.clear
  end
  
  it 'user w/ an empty tag' do
    get :index, :login=>@command.user.login, :tag=>[]
    response.should be_redirect
    flash[:warning].should_not be_blank
  end
  
  it 'redirects when no commands are found' do
    Command.should_receive(:public).and_return([])
    get :index
    response.should be_redirect
    flash[:warning].should_not be_blank
    assigns[:commands].should be_empty
  end
end

describe 'commands/search:' do
  setup_commands_controller_example_group
  
  setup_login_user
  before(:all) {@command = create_command(:user=>@user)}
  
  it 'basic' do
    get :search, :login=>@command.user.login, :q=>@command.keyword
    response.should be_success
    response.should render_template('index')
    assigns[:commands][0].should be_an_instance_of(Command)
  end

  it 'basic w/ empty string' do
    get :search, :login=>@command.user.login, :q=>''
    response.should be_success
    response.should render_template('index')
    flash[:warning].should_not be_blank
    assigns[:commands].should be_empty
  end
  
  #user executing another user's private action
  should_redirect_prohibited_action('search')
end

describe 'commands/tag_add_remove:' do
  setup_commands_controller_example_group
  setup_login_user
  before(:all) {@command = create_command(:user=>@user)}
  
  it 'basic' do
    tag1 = create_tag
    @command.tags << tag1
    command2 = create_command(:user=>@user)
    tag2 = create_tag
    tag3 = create_tag
    command2.tags << tag2
    command2.tags << tag3
    
    lambda {
      get :tag_add_remove, :v=>"#{@command.keyword},#{command2.keyword} -#{tag2.name} -#{tag3.name} sweet"
    }.should change(Tag, :count).by(1)
    response.should be_redirect
    flash[:notice].should_not be_blank
    @command.tag_list.should == [tag1.name, 'sweet']
    command2.tag_list.should == ['sweet']
  end
end

describe 'commands/tag_set:' do
  setup_commands_controller_example_group
  
  setup_login_user
  before(:all) {@command = create_command(:user=>@user)}
  
  it 'basic' do
    command2 = create_command(:user=>@user)
    lambda {
      get :tag_set, :v=>"#{@command.keyword},#{command2.keyword} so awesome"
    }.should change(Tag, :count).by(2)
    response.should be_redirect
    flash[:notice].should_not be_blank
    @command.tag_list.should == ['so', 'awesome']
    command2.tag_list.should == ['so', 'awesome']
  end
  
  it 'warns on blank tags' do
    get :tag_set, :v=>@command.keyword
    response.should be_redirect
    flash[:warning].should match(/No tags/)
  end
   
  it 'warns on no commands found' do
    get :tag_set, :v=>"invalid_command cool"
    response.should be_redirect
    flash[:warning].should match(/Failed.*commands/)
  end
end

describe 'commands/execute:' do
  setup_commands_controller_example_group
  
  before(:all) {@command = create_command}
  
  def basic_expectations
    response.should be_redirect
    assigns[:command].should be_an_instance_of(Command)
    assigns[:result].should_not be_blank
  end
  
  def get_request(hash={})
    get :execute, {:command=>["#{@command.keyword}+blues"], :login=>@command.user.login}.merge(hash)
  end
  
  it 'basic as logged-in user' do
    login_user(@command.user)
    lambda { get_request}.should change(Query, :count).by(1)
    basic_expectations
    query = Query.find_last
    query.command.should == @command
    query.user_id.should eql(@command.user_id)
  end
  
  it 'basic as anonymous user' do
    lambda { get_request}.should change(Query, :count).by(1)
    basic_expectations
    query = Query.find_last
    query.command.should == @command
    query.user_id.should be_nil
  end
  
  it "basic as user running another's command" do
    login_user
    lambda { get_request}.should change(Query, :count).by(1)
    basic_expectations
    query = Query.find_last
    query.command.should == @command
    query.user_id.should_not eql(@command.user_id)
  end
  
  it 'basic w/ no args' do
    lambda { get_request(:command=>[@command.keyword])}.should change(Query, :count).by(1)
    basic_expectations
  end
  
  it 'default_to query'
  
  #this happens when querying other ppl's commands from browser
  it 'basic w/ spaces b/n command + arg' do
    lambda { get_request(:command=>["#{@command.keyword} blues"])}.should change(Query, :count).by(1)
    basic_expectations
  end
  
  it 'nil command w/ default command' do
    @command.user.update_attribute(:default_command_id, create_command(:user=>@user).id)
    lambda { get_request(:command=>['invalid_command'])}.should_not change(Query, :count)
    response.should be_redirect
    assigns[:command].should be_nil
    assigns[:result].should be_nil
  end
  
  it 'nil command w/o default command' do
    lambda { get_request(:command=>['invalid_command'])}.should_not change(Query, :count)
    response.should be_redirect
    assigns[:command].should be_nil
    assigns[:result].should be_nil
    #flash[:warning].should_not be_blank
  end
  
  it 'private command as anonymous user' do
    @command = create_command(:public=>false)
    lambda { get_request}.should_not change(Query, :count)
    response.should be_redirect
    assigns[:command].should be_an_instance_of(Command)
    assigns[:result].should be_nil
  end
  
  it "logged-in user's own private command" do
    @command = create_command(:public=>false)
    login_user(@command.user)
    lambda { get_request}.should change(Query, :count).by(1)
    basic_expectations
  end
  
  it "logged-in user executing someone else's private command" do
    @command = create_command(:public=>false)
    login_user
    lambda { get_request}.should change(Query, :count).by(0)
    response.should be_redirect
    assigns[:command].should be_an_instance_of(Command)
    assigns[:result].should be_nil
  end
  
  it 'stealth query starting w/ !' do
    lambda { get_request(:command=>["!#{@command.keyword}"])}.should_not change(Query, :count)
    response.should be_redirect
    assigns[:result].should_not be_blank
  end
  
  it 'stealth query w/ separate !' do
    lambda { get_request(:command=>["!+#{@command.keyword}"])}.should_not change(Query, :count)
    response.should be_redirect
    assigns[:result].should_not be_blank
  end
  
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
    create_query(:command=>command)
    get :show, :login=>@user.login, :command=>command.keyword
    basic_expectations
    assigns[:queries][0].should be_an_instance_of(Query)
  end
  
  should_redirect_nonexistent_command('show')
  
  should_redirect_nonexistent_user('show')
  
  it "private queries" do
    command = create_command(:user=>@user, :public_queries=>false)
    create_query(:command=>command)
    get :show, :login=>@user.login, :command=>command.keyword
    basic_expectations
    pending("handle querying for private queries correctly")
    assigns[:queries].should be_nil
  end
  
  it "viewing someone else's private command" do
    command = create_command(:public=>false)
    create_query(:command=>command)
    get :show, :login=>command.user.login, :command=>command.keyword
    response.should be_redirect
    flash[:warning].should_not be_blank
  end
  
  it "logged-in user viewing their own private command" do
    command = create_command(:public=>false, :user=>@user)
    create_query(:command=>command)
    login_user(@user)
    get :show, :login=>command.user.login, :command=>command.keyword
    basic_expectations
    assigns[:queries][0].should be_an_instance_of(Query)
  end
  
  it "publicity of user's own command vs another's command"
end

describe 'commands/copy_yubnub_command:' do
  setup_commands_controller_example_group
  
  setup_login_user
  
  #need to mock out open + Hpricot calls
  it "basic"
  it "warns if parsing yubnub man page yields fails"
  
  it "warns if an invalid keyword is given to yubnub" do
    get :copy_yubnub_command, :keyword=>':.junk'
    response.should redirect_to(current_user.home_path)
    flash[:warning].should match(/not.*valid/)
  end
  
  it "warns if no keyword is given to yubnub" do
    get :copy_yubnub_command
    response.should redirect_to(current_user.home_path)
    flash[:warning].should match(/not.*valid/)
  end
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
    flash[:warning].should_not be_blank
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
    flash[:notice].should_not be_blank
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

#update get to delete when changed in code
describe 'commands/destroy:' do
  setup_commands_controller_example_group
  
  setup_login_user
  
  it 'basic' do
    command = create_command(:user=>current_user)
    lambda {
      get 'destroy', :login=>current_user.login, :command=>command.keyword
    }.should change(Command, :count).by(-1)
    response.should be_redirect
    flash[:notice].should_not be_blank
  end
  
  should_redirect_nonexistent_user('destroy')
  should_redirect_nonexistent_command('destroy')
  should_redirect_prohibited_action('destroy')
end

