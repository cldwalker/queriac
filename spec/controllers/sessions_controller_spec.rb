require File.dirname(__FILE__) + '/../spec_helper'

def setup_session_controller_example_group
  controller_name :sessions
  integrate_views
end

describe 'session actions:' do
  setup_session_controller_example_group
  
  it 'new' do
    get :new
    response.should be_success
  end
  
  #should test cookie deletion, wasn't able to set cookie in test
  it 'destroy' do
    delete :destroy
    response.should be_redirect
    flash[:notice].should_not be_blank
    cookies['auth_token'].should be_blank
  end
end

describe 'sessions/create:' do
  setup_session_controller_example_group
  
  before(:all) {
    @user = create_user
    @user.update_attribute(:password, 'blahblah')  
  }
  
  it 'redirects normal login and sets auth_token cookie' do
    cookies['auth_token'].should be_blank
    post :create, :login=>@user.login, :password=>'blahblah', :remember_me=>'1'
    response.should redirect_to(user_home_path(@user))
    #also tests @u.remember_me since that call is needed for cookie to be set
    cookies['auth_token'].should_not be_blank
  end
  
  it 'redirects inactive user' do
    @user.should_receive(:activated?).and_return(false)
    User.should_receive(:authenticate).and_return(@user)
    post :create, :login=>@user.login, :password=>'blahblah'
    flash[:warning].include?('activated').should be_true
    response.should redirect_to(new_session_path)
  end
  
  it 'redisplays login for failed login' do
    post :create, :login=>@user.login, :password=>'doodoo'
    flash[:warning].include?('Problem').should be_true
    response.should be_success
    response.should render_template('new')
  end
  
end