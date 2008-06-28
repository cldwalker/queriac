require File.dirname(__FILE__) + '/../spec_helper'

describe 'static actions:' do
  controller_name :static
  integrate_views
  
  it 'home' do
    query = create_query
    mock_find_top_users(query.user)
    get :home
    response.should be_success
    assigns[:queries][0].should be_an_instance_of(Query)
    assigns[:users][0].should be_an_instance_of(User)
    assigns[:user_commands][0].should be_an_instance_of(UserCommand)
  end
  
  it 'get static pages' do
    static_actions = %w{home setup tutorial}
    static_actions.each do |e|
      get e
      response.should be_success
    end
  end
end
