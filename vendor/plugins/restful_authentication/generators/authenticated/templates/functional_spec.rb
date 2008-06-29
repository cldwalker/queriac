require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe <%= controller_class_name %>Controller do
  fixtures :<%= table_name %>

  it 'should login and redirect' do
    post :create, :login => 'quentin', :password => 'test'
    session[:<%= file_name %>].should_not be_nil
    response.should be_redirect
  end
  
  it 'should fail login and not redirect' do
    post :create, :login => 'quentin', :password => 'bad password'
    session[:<%= file_name %>].should be_nil
    response.should be_success
  end

  it 'should logout' do
    login_as :quentin
    get :destroy
    session[:<%= file_name %>].should be_nil
    response.should be_redirect
  end

  it 'should remember me' do
    post :create, :login => 'quentin', :password => 'test', :remember_me => "1"
    response.cookies["auth_token"].should_not be_nil
  end
  
  it 'should not remember me' do
    post :create, :login => 'quentin', :password => 'test', :remember_me => "0"
    response.cookies["auth_token"].should be_nil
  end

  it 'should delete token on logout' do
    login_as :quentin
    get :destroy
    response.cookies["auth_token"].should == []
  end

  it 'should login with cookie' do
    <%= table_name %>(:quentin).remember_me
    request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    controller.send(:logged_in?).should be_true
  end
  
  it 'should fail expired cookie login' do
    <%= table_name %>(:quentin).remember_me
    <%= table_name %>(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    controller.send(:logged_in?).should_not be_true
  end
  
  it 'should fail cookie login' do
    <%= table_name %>(:quentin).remember_me
    request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    controller.send(:logged_in?).should_not be_true
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
    
  def cookie_for(<%= file_name %>)
    auth_token <%= table_name %>(<%= file_name %>).remember_token
  end
end
