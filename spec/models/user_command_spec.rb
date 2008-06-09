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
end