require File.dirname(__FILE__) + '/../spec_helper'

module CommandsControllerHelper
  #common examples
  def should_redirect_nonexistent_user(action)
    it "redirects nonexistent user" do
      get action, :login=>'invalid_login', :command=>'valid'
      response.should be_redirect
      flash[:warning].should_not be_blank
    end
  end

  def should_redirect_nonexistent_command(action)
    it "redirects nonexistent command" do
      get action, :login=>@user.login, :command=>'bling'
      response.should be_redirect
      assigns[:command].should be_nil
      flash[:warning].include?('has no command').should be_true
    end
  end

  def should_redirect_prohibited_action(action)
    it "redirects a user trying to access another user's private action" do
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
  
  it 'displays commands' do
    Command.should_receive(:public).and_return([@command])
    get :index
    basic_expectations
  end
  
  it 'displays commands by tag' do
    @command.tags << @tag
    get :index, :tag=>[@tag.name]
    basic_expectations
    assigns[:tags].should_not be_empty
    @command.tags.clear
  end
  
  it 'displays commands by multiple tags'
  it "handles publicity of user's own command vs another's command"
  
  it "displays a user's commands" do
    get :index, :login=>@command.user.login
    basic_expectations
    assigns[:user].should be_an_instance_of(User)
  end
  
  it "displays a user's commands by tag" do
    @command.tags << @tag
    get :index, :login=>@command.user.login, :tag=>[@tag.name]
    basic_expectations
    assigns[:tags].should_not be_empty
    assigns[:user].should be_an_instance_of(User)
    @command.tags.clear
  end
  
  it 'redirects when no tag is specified' do
    get :index, :login=>@command.user.login, :tag=>[]
    response.should be_redirect
    flash[:warning].should_not be_blank
  end
  
  it 'redirects when no commands found' do
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
  
  it 'displays results' do
    get :search, :login=>@command.user.login, :q=>@command.keyword
    response.should be_success
    response.should render_template('index')
    assigns[:commands][0].should be_an_instance_of(Command)
  end

  it 'warns and redisplays page for an empty search string' do
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
  
  it 'adds and removes tags' do
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
  
  it 'sets tags' do
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
   
  it 'warns when no commands found' do
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
  
  it 'executes as logged-in user' do
    login_user(@command.user)
    lambda { get_request}.should change(Query, :count).by(1)
    basic_expectations
    query = Query.find_last
    query.command.should == @command
    query.user_id.should eql(@command.user_id)
  end
  
  it 'executes as anonymous user' do
    lambda { get_request}.should change(Query, :count).by(1)
    basic_expectations
    query = Query.find_last
    query.command.should == @command
    query.user_id.should be_nil
  end
  
  it "executes as user running another's command" do
    login_user
    lambda { get_request}.should change(Query, :count).by(1)
    basic_expectations
    query = Query.find_last
    query.command.should == @command
    query.user_id.should_not eql(@command.user_id)
  end
  
  it 'executes w/ no arguments' do
    lambda { get_request(:command=>[@command.keyword])}.should change(Query, :count).by(1)
    basic_expectations
  end
  
  it 'executes default_to query'
  
  #this happens when querying other ppl's commands from browser
  it 'executes w/ spaces between command + argument' do
    lambda { get_request(:command=>["#{@command.keyword} blues"])}.should change(Query, :count).by(1)
    basic_expectations
  end
  
  it 'redirects nil command w/ default command' do
    @command.user.update_attribute(:default_command_id, create_command(:user=>@user).id)
    lambda { get_request(:command=>['invalid_command'])}.should_not change(Query, :count)
    response.should be_redirect
    assigns[:command].should be_nil
    assigns[:result].should be_nil
  end
  
  it 'redirects nil command w/ params[:bad_command]' do
    lambda { get_request(:command=>['invalid_command'])}.should_not change(Query, :count)
    response.should be_redirect
    assigns[:command].should be_nil
    assigns[:result].should be_nil
    #flash[:warning].should_not be_blank
  end
  
  it 'redirects private command as anonymous user' do
    @command = create_command(:public=>false)
    lambda { get_request}.should_not change(Query, :count)
    response.should be_redirect
    assigns[:command].should be_an_instance_of(Command)
    assigns[:result].should be_nil
  end
  
  it "executes private command as command's owner" do
    @command = create_command(:public=>false)
    login_user(@command.user)
    lambda { get_request}.should change(Query, :count).by(1)
    basic_expectations
  end
  
  it 'redirects private command as another user' do
    @command = create_command(:public=>false)
    login_user
    lambda { get_request}.should change(Query, :count).by(0)
    response.should be_redirect
    assigns[:command].should be_an_instance_of(Command)
    assigns[:result].should be_nil
  end
  
  it 'executes stealth query starting w/ !' do
    lambda { get_request(:command=>["!#{@command.keyword}"])}.should_not change(Query, :count)
    response.should be_redirect
    assigns[:result].should_not be_blank
  end
  
  it 'executes stealth query w/ separate !' do
    lambda { get_request(:command=>["!+#{@command.keyword}"])}.should_not change(Query, :count)
    response.should be_redirect
    assigns[:result].should_not be_blank
  end
  
  it 'executes bookmarklet'
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
  
  it "displays public command" do
    command = create_command(:user=>@user)
    create_query(:command=>command)
    get :show, :login=>@user.login, :command=>command.keyword
    basic_expectations
    assigns[:queries][0].should be_an_instance_of(Query)
  end
  
  should_redirect_nonexistent_command('show')
  
  should_redirect_nonexistent_user('show')
  
  it "handle private queries?" do
    command = create_command(:user=>@user, :public_queries=>false)
    create_query(:command=>command)
    get :show, :login=>@user.login, :command=>command.keyword
    basic_expectations
    pending("handle querying for private queries correctly")
    assigns[:queries].should be_nil
  end
  
  it "redirects another's private command" do
    command = create_command(:public=>false)
    create_query(:command=>command)
    get :show, :login=>command.user.login, :command=>command.keyword
    response.should be_redirect
    flash[:warning].should_not be_blank
  end
  
  it "displays private command to command owner" do
    command = create_command(:public=>false, :user=>@user)
    create_query(:command=>command)
    login_user(@user)
    get :show, :login=>command.user.login, :command=>command.keyword
    basic_expectations
    assigns[:queries][0].should be_an_instance_of(Query)
  end
  
  it "handles publicity of user's own command vs another's command"
end

describe 'commands/copy_yubnub_command:' do
  setup_commands_controller_example_group
  
  setup_login_user
  
  #need to mock out open + Hpricot calls
  it "copies yubnub command"
  it "warns if parsing yubnub man page yields fails"
  
  it "warns if an invalid keyword is given to yubnub" do
    get :copy_yubnub_command, :keyword=>':.junk'
    response.should redirect_to(user_home_path(current_user))
    flash[:warning].should match(/not.*valid/)
  end
  
  it "warns if no keyword is given to yubnub" do
    get :copy_yubnub_command
    response.should redirect_to(user_home_path(current_user))
    flash[:warning].should match(/not.*valid/)
  end
end

describe 'commands/new:' do
  setup_commands_controller_example_group
  
  setup_login_user
  before(:all) { @command_hash = random_valid_command_attributes.dup.merge(:description=>'coolness') }
  
  it "displays page" do
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
  
  it "displays prepopulated page" do
    get 'new', @command_hash.dup
    all_expectations
  end
  
  it "displays page w/ public ancestor" do
    ancestor = stub('ancestor', @command_hash.merge(:'public?'=>true, :tag_string=>''))
    Command.should_receive(:find).and_return(ancestor)
    get 'new', :ancestor=>'mock_id'
    all_expectations
  end
  
  it "displays page w/ private ancestor when command owner " do
    ancestor = stub('ancestor', @command_hash.merge(:'public?'=>false, :tag_string=>'', :user=>current_user))
    Command.should_receive(:find).and_return(ancestor)
    get 'new', :ancestor=>'mock_id'
    all_expectations
  end
  
  it "redirects private ancestor when anonymous user" do
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
  
  it 'displays form' do
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
  
  it 'creates command' do
    lambda { post_request }.should change(Command, :count).by(1)
    response.should be_redirect
    flash[:notice].should_not be_blank
    assigns[:command].should be_an_instance_of(Command)
    assigns[:command].user.should == @user
  end
  
  it 'redisplays invalid submission' do
    command = Command.new
    command.stub!(:save).and_return(false)
    Command.should_receive(:new).and_return(command)
    lambda { post_request}.should_not change(Command, :count)
    response.should be_success
    assigns[:command].should be_an_instance_of(Command)
    response.should render_template(:new)
  end
  
  it 'imports commands w/ bookmarks file' do
    mock_file = stub('file', :read=>"bookmark info", :'blank?'=>false)
    Command.should_receive(:create_commands_for_user_from_bookmark_file).with(@user, anything).and_return([1,2])
    post :create, :bookmarks_file=>mock_file
    response.should be_redirect
    flash[:notice].should_not be_blank
  end
  
  it 'warns if given invalid bookmarks file' do
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
    
  it 'updates command' do
    command = create_command(:user=>@user)
    put :update, :id=>command.id, :command=>{:name=>'another name'}, :tags=>''
    command.reload.name.should eql('another name')
    response.should be_redirect
    flash[:notice].should_not be_blank
  end
  
  it "redirects a prohibited action" do
    command = create_command
    put :update, :id=>command.id, :command=>{:name=>'another name'}, :tags=>''    
    response.should be_redirect
    flash[:warning].should match(/not allowed/)
  end
  
  it 'redisplays invalid submission' do
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
  
  it 'destroys command' do
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

