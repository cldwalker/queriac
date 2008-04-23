require File.dirname(__FILE__) + '/../spec_helper'
module UsersControllerHelper
end

def setup_users_controller_example_group
  controller_name :users
  integrate_views
  extend UsersControllerHelper
end

describe 'users/new:' do
  setup_users_controller_example_group
  
  it 'basic' do
    get :new
    response.should be_success
  end
end

describe 'users/show:' do
  setup_users_controller_example_group
  before(:all) { 
    @command = create_command(:kind=>'parametric')
    #activate user in order to have @users
    @command.user.activate
    @command.tags << create_tag
    create_query(:command=>@command)
    create_query(:command=>create_command(:user=>@command.user, :kind=>'shortcut'))
    create_query(:command=>create_command(:user=>@command.user, :bookmarklet=>true))    
  }
  
  def basic_expectations
    response.should be_success
    assigns[:user].should be_an_instance_of(User)
    assigns[:tags][0].should be_an_instance_of(Tag)
    assigns[:users][0].should be_an_instance_of(User)
  end
  
  it 'basic' do
    get :show, :login=>@command.user.login
    basic_expectations
    assigns[:commands][0].should be_an_instance_of(Command)
  end
  
  it 'show command types as command user' do
    mock_user = @command.user
    mock_user.queries.should_receive(:count).and_return(101)
    login_user mock_user
    
    get :show, :login=>@command.user.login
    basic_expectations
    assigns[:quicksearches][0].should be_an_instance_of(Command)
    assigns[:shortcuts][0].should be_an_instance_of(Command)
    assigns[:bookmarklets][0].should be_an_instance_of(Command)
  end
  
  it 'show command types as another user' do
    mock_user = @command.user
    mock_user.queries.should_receive(:count).and_return(101)
    User.should_receive(:find_by_login).and_return(mock_user)
    login_user
    
    get :show, :login=>@command.user.login
    basic_expectations
    assigns[:quicksearches][0].should be_an_instance_of(Command)
    assigns[:shortcuts][0].should be_an_instance_of(Command)
    assigns[:bookmarklets][0].should be_an_instance_of(Command)
  end
  
  it 'show bad command'
  it 'show private command'
  it 'show illegal command'
end

describe 'users/create:' do
  setup_users_controller_example_group
  
  it 'basic' do
    lambda {
    lambda { post :create, :user=>random_valid_user_attributes }.should change(User, :count).by(1)
    }.should change(Command, :count).by_at_least(8)
    response.should be_redirect
    flash[:notice].should_not be_blank
  end
  
  it 'invalid params' do
    invalid_attributes = random_valid_user_attributes
    invalid_attributes.delete(:login)
    lambda {post :create, :user=>invalid_attributes}.should_not change(User,:count)
    response.should be_success
    response.should render_template('new')
    assigns[:user].should be_an_instance_of(User)
  end
end

describe 'users/edit:' do
  setup_users_controller_example_group
  
  it 'basic' do
    login_user
    get :edit
    response.should be_success
    assigns[:user].should be_an_instance_of(User)
  end
  
  it 'basic as anonymous user (tutorial)'
end


describe 'misc' do
  setup_users_controller_example_group
  it 'users/update'
  it 'users/activate'
  it 'users/destroy'
end