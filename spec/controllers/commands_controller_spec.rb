require File.dirname(__FILE__) + '/../spec_helper'

describe 'commands/new:' do
  controller_name :commands
  integrate_views
  
  before(:each) do
    login_user
   #should use valid_command_attributes
    @command_hash = {:name=>'bozo', :keyword=>'d', :url=>'http://dictionary.com', :description=>'dictionary'}
  end
  
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
  
  it "w/ prepopulation" do
    get 'new', @command_hash.dup
    all_expectations
  end
  
  it "w/ public ancestor" do
    ancestor = stub('ancestor', @command_hash.merge(:'public?'=>true, :tag_string=>''))
    Command.should_receive(:find).and_return(ancestor)
    get 'new', :ancestor=>'mock_id'
    all_expectations
  end
  
  it "w/ your own private ancestor" do
    ancestor = stub('ancestor', @command_hash.merge(:'public?'=>false, :tag_string=>'', :user=>current_user))
    Command.should_receive(:find).and_return(ancestor)
    get 'new', :ancestor=>'mock_id'
    all_expectations
  end
  
  it "w/ someone else's private ancestor" do
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
  
  before(:each) do
    login_user
  end
  
  it 'basic' do
    #TODO: move this creation into a helper method
    current_user.commands.create(:keyword=>'bl', :url=>'http://bl.com/%q', :name=>'bl')
    get 'edit', :login=>current_user.login, :command=>'bl'
    response.should be_success
    response.should render_template('edit')
    assigns[:command].should be_an_instance_of(Command)
  end
  
  it "accessing someone else's edit" do
    get 'edit', :login=>create_user.login, :command=>'some_command'
    response.should be_redirect
    flash[:warning].should match(/not allowed/)
  end
  
  it "nonexistent command" do
    get 'edit', :login=>current_user.login, :command=>'bling'
    response.should be_redirect
    assigns[:command].should be_nil
    flash[:warning].should match(/doesn't.*exist/)
  end
  
  it "nonexistent user" do
    get 'edit', :login=>'invalid_login', :command=>'valid'
    response.should be_redirect
    flash[:warning].should_not be_nil
  end    
end
