require File.dirname(__FILE__) + '/../spec_helper'

describe 'commands/new:' do
  controller_name :commands
  integrate_views
  
  before(:each) do
    login_user
    @controller.instance_eval("@user = self.current_user") #load_user_from_param
  end
  
  it "basic" do
    get 'new'
    assigns[:command].should be_an_instance_of(Command)
    response.should render_template(:new)
  end
  
  it "w/ prepopulation" do
    command_hash = {:name=>'bozo', :keyword=>'d', :url=>'http://dictionary.com', :description=>'dictionary'}
    get 'new', command_hash.dup
    assigns[:command].should be_an_instance_of(Command)
    command_hash.values.sort.should eql(assigns[:command].attributes.symbolize_keys.only(*command_hash.keys).values.sort)
    response.should render_template(:new)
  end
  
  it "w/ public ancestor" do
    command_hash = {:name=>'bozo', :keyword=>'d', :url=>'http://dictionary.com', :description=>'dictionary'}
    ancestor = stub('ancestor', command_hash.merge(:'public?'=>true, :tag_string=>''))
    Command.should_receive(:find).and_return(ancestor)
    get 'new', :ancestor=>'mock_id'
    command_hash.values.sort.should eql(assigns[:command].attributes.symbolize_keys.only(*command_hash.keys).values.sort)
    response.should render_template(:new)
  end
  
  it "w/ someone else's private ancestor"
  it "w/ your own private ancestor"
end