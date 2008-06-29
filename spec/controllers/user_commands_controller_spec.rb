require File.dirname(__FILE__) + '/../spec_helper'

def setup_user_commands_controller_example_group
  controller_name :user_commands
  integrate_views
end

describe 'user_commands/show:' do
  setup_user_commands_controller_example_group
  
  it 'displays public command'
  it "gets no queries for another's private queries"
  # it "gets no queries for another's private queries" do
  #   command = create_command(:user=>@user, :public_queries=>false)
  #   create_query(:command=>command)
  #   get :show, :login=>@user.login, :command=>command.to_param
  #   basic_expectations
  #   assigns[:queries].should be_nil
  # end
  
  it "redirects another's private command"
  it "displays private command to command owner"
  it "handles publicity of user's own command vs another's command"
end

describe 'user_commands/index:' do
  setup_user_commands_controller_example_group
  it 'by user'
  it 'by user + tags'
  it 'by tags'
  it 'all public'
  it 'rss'
  it 'command_user_commands'
end
 
describe 'user_commands/new:' do
  setup_user_commands_controller_example_group
  setup_login_user
  
  def basic_expectations
    response.should be_success
    assigns[:user_command].should be_an_instance_of(UserCommand)
  end
  
  def all_expectations
    basic_expectations
    #ensure command is populated with values from params or ancestor
    assigns[:user_command].attributes.symbolize_keys.slice(*@ucommand_hash.keys).should == @ucommand_hash
  end
  
  it "displays page" do
    get 'new'
    basic_expectations
  end
  
  it "displays prepopulated page" do
    @ucommand_hash = random_valid_command_attributes.dup.merge(:description=>'coolness')
    get 'new', @ucommand_hash.dup
    all_expectations
  end
  
  it 'displays copy command, prefills fields' do
    ucommand = create_user_command
    get :copy, :id=>ucommand.id
    basic_expectations
    assigns[:original_command].should be_an_instance_of(UserCommand)
    assigns[:user_command].name.should == ucommand.name
    response.should have_tag('#user_command_command_id')
    assigns[:disabled_fields].should_not be_empty
    #hidden/disabled checkboxes
    response.should have_tag('#user_command_url[disabled=disabled]')
    response.should_not have_tag('#user_command_public')
  end
  
  it 'redirects copying private command' do
    ucommand = create_user_command(:command=>create_command(:public=>false))
    get :copy, :id=>ucommand.id
    response.should be_redirect
    flash[:warning].should_not be_blank
  end
  
  it 'redirects copying your own command'
  
end

describe 'user_commands/create:' do
  setup_user_commands_controller_example_group
  setup_login_user
  
  def post_request(hash={})
    user_command_hash = random_valid_command_attributes.merge(:url_encode=>'0', :http_post=>'1', :public_queries=>'1', :public=>'1').merge(hash)
    post :create, :user_command=>user_command_hash, :tags=>''
  end
  
  def basic_expectations(options={})
    response.should be_redirect
    flash[:notice].should_not be_blank
    assigns[:user_command].should be_an_instance_of(UserCommand)
    assigns[:user_command].user.should == @user
    unless options[:ignore_common_attributes]
      common_attributes = %w{url user_id http_post url_encode}
      assigns[:user_command].attributes.slice(*common_attributes).should == assigns[:user_command].command.attributes.slice(*common_attributes)
    end
  end
  
  it 'redisplays invalid submission' do
    ucommand = UserCommand.new
    #rspec bug: http://rubyforge.org/pipermail/rspec-users/2008-June/007396.html
    pending 'rspec stub! bug'
    ucommand.stub!(:save).and_return(false)
    UserCommand.should_receive(:new).and_return(ucommand)
    lambda { post_request}.should_not change(Command, :count)
    response.should be_success
    assigns[:user_command].should be_an_instance_of(UserCommand)
    response.should render_template(:new)
  end
  
  it 'copies usercommand' do
    command = create_command
    lambda {
      lambda { post_request(:command_id=>command.id, :url=>nil)}.should_not change(Command, :count)
    }.should change(UserCommand, :count).by(1)
    basic_expectations(:ignore_common_attributes=>true)
    assigns[:user_command].command == command
  end
  
  it 'creates new public command' do
    lambda {
      lambda { post_request }.should change(Command, :count).by(1)
    }.should change(UserCommand, :count).by(1)
    basic_expectations
  end
  
  it 'creates public user command and points to existing public command' do
    command = create_command(:user=>@user)
    lambda {
      lambda {
        post_request(:url=>command.url) 
      }.should_not change(Command, :count)
    }.should change(UserCommand, :count).by(1)
    basic_expectations(:ignore_common_attributes=>true)
    assigns[:user_command].command == command
    pending 'notify user of existing command?'
  end
  
  it 'creates public command if existing command is private' do
    command = create_command(:user=>@user, :public=>false)
    lambda {
      lambda {
        post_request(:url=>command.url) 
      }.should change(Command, :count).by(1)
    }.should change(UserCommand, :count).by(1)
    basic_expectations
    assigns[:user_command].command != command
  end
  
  it 'creates new private command' do
    lambda {
      lambda { post_request(:public=>'0') }.should change(Command, :count).by(1)
    }.should change(UserCommand, :count).by(1)
    basic_expectations
  end
  
  it 'creates private command if existing command is public' do
    command = create_command(:user=>@user, :public=>true)
    lambda {
      lambda {
        post_request(:url=>command.url, :public=>'0')
      }.should change(Command, :count).by(1)
    }.should change(UserCommand, :count).by(1)
    basic_expectations
    assigns[:user_command].command != command
  end
  
  it 'creates private command if existing command is private' do
    command = create_command(:user=>@user, :public=>false)
    lambda {
      lambda {
        post_request(:url=>command.url, :public=>'0')
      }.should change(Command, :count).by(1)
    }.should change(UserCommand, :count).by(1)
    basic_expectations
    assigns[:user_command].command != command
  end
  
  it "when no command is set, adds error to command and sends email to admins with failing params." do
    Command.should_receive(:create).and_return(nil)
    lambda { lambda {post_request}.should_not change(Command, :count) }.should_not change(UserCommand, :count)
    response.should be_success
    response.should render_template('new')
    assigns[:user_command].should be_an_instance_of(UserCommand)
    assigns[:user_command].errors.size.should == 1
    assigns[:user_command].errors[:command_id].should_not be_nil
    pending 'send email to admin with failing params?'
  end
  
  it "warns against creating same user command by url for given user" do
    user_command = create_user_command(:user=>@user)
    lambda {
      lambda {
        post_request(:url=>user_command.command.url)
      }.should_not change(Command, :count)
    }.should_not change(UserCommand, :count)
    response.should render_template('new')
    should_have_flash_now_warning_tag
    assigns[:user_command].should be_an_instance_of(UserCommand)
    assigns[:user_command].errors.size.should == 1
    assigns[:user_command].errors[:command_id].should_not be_nil    
  end
end

describe 'user_commands/edit:' do
  setup_user_commands_controller_example_group
  setup_login_user
  before(:all) {@user_command = create_user_command(:user=>@user)}
  
  def basic_expectations
    response.should be_success
    assigns[:user_command].should be_an_instance_of(UserCommand)
  end
  
  it "hides url + public for command user" do
    user_command = create_user_command(:command=>create_command, :user=>@user)
    get :edit, :id=>user_command.to_param
    basic_expectations
    #TODO: make array matcher
    (assigns[:disabled_fields] - [:url, :public]).should be_empty
  end
  
  it "displays page + hides no fields for command owner when command is editable" do
    @user_command.command_editable?.should be_true
    get :edit, :id=>@user_command.to_param
    basic_expectations
    assigns[:disabled_fields].should be_empty
  end
  
  it "hides public for command owner when command isn't editable" do
    pending 'rspec stub! bug'
    @user_command.stub!('command_editable?').and_return(false)
    UserCommand.should_receive(:find_by_keyword).and_return(@user_command)
    get :edit, :id=>@user_command.to_param
    basic_expectations
    assigns[:disabled_fields].should == [:public]
  end
end

describe 'user_commands/update:' do
  setup_user_commands_controller_example_group
  setup_login_user
  before(:all) { @user_command = create_user_command(:user=>@user)}
  
  def basic_expectations
    response.should be_redirect
    flash[:notice].should_not be_blank
  end
  
  it 'owner updates user_command fields' do
    put :update, :id=>@user_command.to_param, :user_command=>{:name=>'another name'}, :tags=>''
    basic_expectations
    @user_command.reload.name.should eql('another name')
  end
  
  it 'owner updates command fields' do
    @user_command.command.http_post.should be_false
    put :update, :id=>@user_command.to_param, :user_command=>{:http_post=>'1', :url=>'bling.com'}, :tags=>''
    basic_expectations
    @user_command.command.reload.http_post.should be_true
    @user_command.command.url.should == 'bling.com'
  end
  
  it "user can't update command fields " do
    @user_command = create_user_command(:command=>create_command, :user=>@user)
    @user_command.command.http_post.should be_false
    put :update, :id=>@user_command.to_param, :user_command=>{:http_post=>'1', :url=>'bling.com'}, :tags=>''
    basic_expectations
    @user_command.command.reload.http_post.should be_false
    @user_command.command.url.should_not == 'bling.com'
  end
  
  it "user can't update their own command's url" do
    user_command = create_user_command(:command=>create_command, :user=>@user)
    lambda {
      put :update, :id=>user_command.to_param, :user_command=>{:url=>'http://mycommand.com'}, :tags=>''
    }.should_not change(user_command, :url)
    basic_expectations
  end
  
  it 'updates restricted public field if command is editable' do
    @user_command.command_editable?.should be_true
    @user_command.public?.should be_true
    put :update, :id=>@user_command.to_param, :user_command=>{:public=>'0'}, :tags=>''
    basic_expectations
    @user_command.reload.public.should == false
  end
  
  it "doesn't update restricted field public if command is not editable" do
    pending 'FIXME'
    #create_user_command(:command=>@user_command.command)
    @user_command.command_editable?.should be_false
    #@user_command.public?.should be_true #FIX?
    put :update, :id=>@user_command.to_param, :user_command=>{:public=>'0', :name=>'coolness'}, :tags=>''
    basic_expectations
    @user_command.reload.public?.should == false
  end

  it 'redisplays invalid submission' do
    pending 'rspec stub! bug'
    @user_command.stub!(:update_attributes).and_return(false)
    UserCommand.should_receive(:find_by_keyword).and_return(@user_command)
    put :update, :id=>@user_command.to_param, :user_command=>{:name=>'another name'}, :tags=>''
    response.should be_success
    response.should render_template('edit')
  end
end

describe 'user_commands/import:' do
  setup_user_commands_controller_example_group  
  setup_login_user
  
  it 'displays import page' do
    get :import
    response.should be_success
  end
  
  it 'imports commands w/ bookmarks file' do
    mock_file = stub('file', :read=>"bookmark info", :'blank?'=>false)
    Command.should_receive(:create_commands_for_user_from_bookmark_file).with(@user, anything).and_return([[create_user_command],[]])
    post :import, :bookmarks_file=>mock_file
    response.should be_success
    response.should render_template(:import)
    flash[:notice].should_not be_blank
    assigns[:user_commands][0].should be_an_instance_of(UserCommand)
  end
  
  it 'warns if given invalid bookmarks file' do
    post :import, :bookmarks_file=>''
    response.should be_success
    response.should render_template(:import)
    flash[:warning].should_not be_blank
  end
end

describe 'user_command actions:' do
  setup_user_commands_controller_example_group
  
  setup_login_user
  it 'destroys user command' do
    login_user
    user_command = create_user_command(:user=>current_user)
    lambda {
      lambda {
        delete 'destroy', :id=>user_command.to_param
      }.should change(UserCommand, :count).by(-1)
    }.should_not change(Command, :count)
    response.should be_redirect
    flash[:notice].should_not be_blank
  end
  
  it 'update_url'
  
  it 'search: displays results' do
    user_command = create_user_command
    login_user user_command.user
    get :search, :q=>user_command.keyword
    response.should be_success
    response.should render_template('index')
    assigns[:user_commands][0].should be_an_instance_of(UserCommand)
  end
  
    it 'search: warns and redisplays page for an empty search string' do
      user_command = create_user_command
      login_user user_command.user
      get :search, :q=>''
      response.should be_success
      response.should render_template('index')
      flash[:warning].should_not be_blank
      assigns[:user_commands].should be_empty
    end
  
end

describe 'user_commands/tag_set:' do
  setup_user_commands_controller_example_group
  
  setup_login_user
  before(:all) {@ucommand = create_user_command(:user=>@user)}
  
  it 'sets tags' do
    ucommand2 = create_user_command(:user=>@user)
    lambda {
      get :tag_set, :v=>"#{@ucommand.keyword},#{ucommand2.keyword} so awesome"
    }.should change(Tag, :count).by(2)
    response.should be_redirect
    flash[:notice].should_not be_blank
    @ucommand.tag_list.should == ['so', 'awesome']
    ucommand2.tag_list.should == ['so', 'awesome']
  end
  
  it 'warns on blank tags' do
    get :tag_set, :v=>@ucommand.keyword
    response.should be_redirect
    flash[:warning].should match(/No tags/)
  end
   
  it 'warns when no commands found' do
    get :tag_set, :v=>"invalid_command cool"
    response.should be_redirect
    flash[:warning].should match(/Failed.*commands/)
  end
end

describe 'user_commands/tag_add_remove:' do
  setup_user_commands_controller_example_group
  setup_login_user
  before(:all) {@ucommand = create_user_command(:user=>@user)}
  
  it 'adds and removes tags' do
    tag1 = create_tag
    @ucommand.tags << tag1
    ucommand2 = create_user_command(:user=>@user)
    tag2 = create_tag
    tag3 = create_tag
    ucommand2.tags << tag2
    ucommand2.tags << tag3
    
    lambda {
      get :tag_add_remove, :v=>"#{@ucommand.keyword},#{ucommand2.keyword} -#{tag2.name} -#{tag3.name} sweet"
    }.should change(Tag, :count).by(1)
    response.should be_redirect
    flash[:notice].should_not be_blank
    @ucommand.tag_list.should == [tag1.name, 'sweet']
    ucommand2.tag_list.should == ['sweet']
  end
end

__END__

# 
# describe 'commands/copy_yubnub_command:' do
#   setup_commands_controller_example_group
#   
#   setup_login_user
#   
#   #need to mock out open + Hpricot calls
#   it "copies yubnub command"
#   it "warns if parsing yubnub man page yields fails"
#   it 'handles copying yubnub-specific commands'
#   
#   it "warns if an invalid keyword is given to yubnub" do
#     get :copy_yubnub_command, :keyword=>':.junk'
#     response.should redirect_to(user_home_path(current_user))
#     flash[:warning].should match(/not.*valid/)
#   end
#   
#   it "warns if no keyword is given to yubnub" do
#     get :copy_yubnub_command
#     response.should redirect_to(user_home_path(current_user))
#     flash[:warning].should match(/not.*valid/)
#   end
# end
# 

