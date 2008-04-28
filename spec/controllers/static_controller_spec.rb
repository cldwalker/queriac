require File.dirname(__FILE__) + '/../spec_helper'

describe 'static actions:' do
  controller_name :static
  integrate_views
  
  it 'home' do
    query = create_query
    User.should_receive(:find_top_users).and_return([query.user])
    get :home
    response.should be_success
    assigns[:queries][0].should be_an_instance_of(Query)
    assigns[:users][0].should be_an_instance_of(User)
  end
  
  it 'help' do
    get :help
    response.should be_success
  end
end
