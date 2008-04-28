require File.dirname(__FILE__) + '/../spec_helper'

def setup_queries_controller_example_group
  controller_name :queries
  integrate_views
end

describe 'queries/index:' do
  setup_queries_controller_example_group
  
  before(:all) { @query = create_query; @command = @query.command; @tag = create_tag}
  
  def basic_expectations
    response.should be_success
    assigns[:queries][0].should be_an_instance_of(Query)
  end
  
  it 'displays queries' do
    get :index
    basic_expectations
  end
  
  it 'displays queries by tag' do
    @command.tags << @tag
    get :index, :tag=>[@tag.name]
    basic_expectations
    assigns[:tags].should_not be_empty
    @command.tags.clear
  end
  
  it 'displays queries by multiple tags'
  
  it 'displays user queries' do
    get :index, :login=>@command.user.login
    basic_expectations
    assigns[:user].should be_an_instance_of(User)
  end
  
  it 'displays user queries by tag' do
    @command.tags << @tag
    get :index, :login=>@command.user.login, :tag=>[@tag.name]
    basic_expectations
    assigns[:tags].should_not be_empty
    assigns[:user].should be_an_instance_of(User)
    @command.tags.clear
  end
  
  it 'handles user publicity'
  it 'handles query publicity'
  
  it "displays public command queries" do
    get :index, :command=>@command.keyword, :login=>@command.user.login
    basic_expectations
    assigns[:command].should be_an_instance_of(Command)
    assigns[:user].should be_an_instance_of(User)
  end
  
  it "displays private command queries to command's owner" do
    @command.update_attribute(:public_queries, false)
    login_user @query.command.user
    get :index, :command=>@command.keyword, :login=>@command.user.login
    basic_expectations
    assigns[:command].should be_an_instance_of(Command)
    assigns[:user].should be_an_instance_of(User)
    @command.update_attribute(:public_queries, true)
  end
  
  it "redirects user for trying to view another's private command queries" do
    @command.update_attribute(:public_queries, false)
    login_user
    get :index, :command=>@command.keyword, :login=>@command.user.login
    response.should be_redirect
    flash[:warning].should_not be_blank
    assigns[:command].should be_an_instance_of(Command)
    assigns[:user].should be_an_instance_of(User)
    @command.update_attribute(:public_queries, true)
  end
  
  it 'redirects when no queries found' do
    Query.should_receive(:find).and_return([])
    get :index
    response.should be_redirect
    flash[:warning].should_not be_blank
    assigns[:queries].should be_empty
  end
  
end