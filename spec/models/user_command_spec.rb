require File.dirname(__FILE__) + '/../spec_helper'

describe UserCommand do
  before(:all) do
    @user_command = create_user_command
  end
  
  it "should update tags" do
    @user_command.update_tags("this that other")
    @user_command.should have(3).tags
    @user_command.tags.first.name.should eql("this")
    @user_command.tags.last.name.should eql("other")
  end
  
  it "should generate space-delimited tag string" do
    @user_command.update_tags("this that other")
    @user_command.tag_string.should eql("this that other")
  end
  
  it "is valid when url and url options match" do
    uc = create_user_command(:url=>'http://a.com/[:q]/show', :url_options=>[{:name=>'q'}])
    uc.should be_valid
  end
  
  it "is invalid and has errors when url and url options mismatch" do
    uc = create_user_command(:url=>'http://a.com/[:q]/show', :url_options=>[{:name=>'d'}])
    uc.should_not be_valid
    uc.errors.on(:url_options).should_not be_blank
  end
  
  it "url options nil if optionless command" do
    uc = create_user_command(:url=>"http://a.com")
    uc.read_attribute(:url_options).should be_nil
  end
  
  it "merge_url_options_with_options_in_url" do
    @user_command.url_options = [{:name=>'type', :option_type=>'normal'}, {:name=>'old'}]
    expected_options = [{:name=>"type", :option_type=>"normal"}, {:name=>"page"}]
    @user_command.merge_url_options_with_options_in_url("http://example.com?type=[:type]&page=[:page]").should == expected_options
  end
  
end

describe 'misc methods:' do
  it "before_destroy updates command's queries_count_all and users_count" do
    user_command = create_user_command(:command=>create_command(:queries_count_all=>40), :queries_count=>10)
    command = user_command.command
    lambda {
    lambda {
      user_command.destroy
    }.should change(command, :queries_count_all).by(-10)
    }.should change(command, :users_count).by(-1)
  end
  
  it "after_create updates command's users_count" do
    command = create_command
    lambda {
      create_user_command(:command=>command)
    }.should change(command, :users_count).by(1)
  end
end