require File.dirname(__FILE__) + '/../spec_helper'

def setup_users_controller_example_group
  controller_name :users
  integrate_views
end

describe 'user actions:' do
  setup_users_controller_example_group
  
  it 'new' do
    get :new
    response.should be_success
  end
  
  it 'index' do
    #mock User.paginate_users
    user = create_user
    user.stub!(:user_commands_count).and_return(1)
    User.should_receive(:find).and_return([user])
    
    get :index
    response.should be_success
    assigns[:users][0].should be_an_instance_of(User)
  end
  
  it 'home' do
    login_user
    get :home
    response.should be_success
    assigns[:user].should be_an_instance_of(User)
  end
  
  it 'opensearch'
end

describe 'users/show:' do
  setup_users_controller_example_group
  before(:all) { 
    @command = create_command(:kind=>'parametric')
    ucommand = create_user_command(:command=>@command, :user=>@command.user)
    ucommand.tags << create_tag
    #setup @users
    @active_user = create_user
    @active_user.activate

    create_query(:user_command=>ucommand)
    create_query(:user_command=>create_user_command(:user=>@command.user, :command=>create_command(:kind=>'shortcut')))
    create_query(:user_command=>create_user_command(:user=>@command.user, :command=>create_command(:bookmarklet=>true)))
  }
  
  def basic_expectations
    response.should be_success
    assigns[:user].should be_an_instance_of(User)
    assigns[:tags][0].should be_an_instance_of(Tag)
    assigns[:users][0].should be_an_instance_of(User)
  end
  
  it "displays a simple user's homepage" do
    mock_find_top_users(@active_user)
    get :show, :login=>@command.user.login
    basic_expectations
    assigns[:user_commands][0].should be_an_instance_of(UserCommand)
  end
  
  it "displays advanced user's homepage to advanced user" do
    mock_user = @command.user
    mock_user.queries.should_receive(:count).and_return(101)
    login_user mock_user
    mock_find_top_users(@active_user)
    
    get :show, :login=>@command.user.login
    basic_expectations
    assigns[:quicksearches][0].should be_an_instance_of(UserCommand)
    assigns[:shortcuts][0].should be_an_instance_of(UserCommand)
    assigns[:bookmarklets][0].should be_an_instance_of(UserCommand)
  end
  
  it "displays advanced user's homepage to another user" do
    mock_user = @command.user
    mock_user.queries.should_receive(:count).and_return(101)
    User.should_receive(:find_by_login).and_return(mock_user)
    login_user
    mock_find_top_users(@active_user)
    
    get :show, :login=>@command.user.login
    basic_expectations
    assigns[:quicksearches][0].should be_an_instance_of(UserCommand)
    assigns[:shortcuts][0].should be_an_instance_of(UserCommand)
    assigns[:bookmarklets][0].should be_an_instance_of(UserCommand)
  end
  
  it 'redirects when no user specified' do
    get :show
    response.should be_redirect
    flash[:warning].should_not be_blank
  end
  
  it 'displays bad command'
  it 'displays private command'
  it 'displays illegal command'
  it "publicity of user's user commands"
end

describe 'users/create:' do
  setup_users_controller_example_group
  
  it 'creates a user' do
    lambda { post :create, :user=>random_valid_user_attributes }.should change(User, :count).by(1)
    response.should be_redirect
    flash[:notice].should_not be_blank
  end
  
  it 'redisplays invalid submission' do
    invalid_attributes = random_valid_user_attributes
    invalid_attributes.delete(:login)
    lambda {post :create, :user=>invalid_attributes}.should_not change(User,:count)
    response.should be_success
    response.should render_template('new')
    assigns[:user].should be_an_instance_of(User)
  end
  
  it "doesn't create when bot param is filled in"
end

describe 'users/edit:' do
  setup_users_controller_example_group
  
  it 'displays page' do
    login_user
    get :edit
    response.should be_success
    assigns[:user].should be_an_instance_of(User)
  end
  
end

describe 'users/update:' do
  setup_users_controller_example_group
  
  it 'updates user including use default command boolean' do
    login_user :default_command_id=>1
    current_user.default_command_id.should_not be_nil
    put :update, :user=>{:login=>'cool'}, :use_default_command=>'no'
    response.should be_redirect
    flash[:notice].should_not be_blank
    current_user.reload
    current_user.login.should == 'cool'
    current_user.default_command_id.should be_nil
  end
  
  it 'redisplays invalid submission' do
    user = create_user
    user.stub!(:update_attributes).and_return(false)
    login_user user
    put :update, :user=>{:login=>'cool'}
    response.should be_success
    response.should render_template('edit')
    assigns[:user].should be_an_instance_of(User)
    current_user.reload.login.should_not == 'cool'
  end
end

describe 'users/activate:' do
  setup_users_controller_example_group
  
  before(:each) { @user = create_user; @user.send(:make_activation_code); @user.save}
  
  it 'activates user and redirects' do
    lambda {
      get :activate, :activation_code=>@user.activation_code
    }.should change(UserCommand, :count).by_at_least(8)
    
    response.should redirect_to(setup_path)
    flash[:notice].should_not be_blank
    @user.reload.should be_activated
  end
  
  it 'warns and redirects for invalid activation' do
    get :activate, :activation_code=>'XXXXXXX'
    response.should redirect_to(setup_path)
    flash[:warning].should_not be_blank
    @user.reload.should_not be_activated
  end
end

#enable once user destroy is used
# describe 'users/destroy:' do
#   setup_users_controller_example_group
#   before(:each) {@user = login_user; create_command(:user=>@user)}
#   
#   it 'deletes user and their commands' do
#     lambda {
#     lambda {
#       delete :destroy
#     }.should change(User, :count).by(-1)
#     }.should_not change(Command, :count)
#     response.should be_redirect
#     flash[:notice].should_not be_blank
#   end
# end