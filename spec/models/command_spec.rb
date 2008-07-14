require File.dirname(__FILE__) + '/../spec_helper'

module CommandSpecHelper
  
  def valid_command_attributes
    {
      :name => "Google Search",
      :keyword => "g",
      :url  => "http://google.com/search?q=(q)"
    }
  end
  
end


describe Command do
  
  include CommandSpecHelper
  
  before(:each) do
    @command = Command.new
  end

  it "should be valid" do
    @command.attributes = valid_command_attributes
    @command.should be_valid
  end
  
  it "should require name" do
    @command.attributes = valid_command_attributes.except(:name)
    @command.should have(1).error_on(:name)
  end
  
  it "should prevent saving of commands with reserved stopwords" do
    COMMAND_STOPWORDS.should_not be_empty
    for word in COMMAND_STOPWORDS
      # puts "Checking for invalidity of #{word}"
      @command.attributes = valid_command_attributes.with(:keyword => word)
      @command.should_not be_valid
    end
  end
  
  it "should clean up command after validation" do
    @command.attributes = valid_command_attributes.with(:keyword => "G", :url => "http://google.com/search?q=%s")
    @command.save
    @command.keyword.should eql("g")
    @command.url.should eql("http://google.com/search?q=(q)")
  end

  it "should be parametric" do
    @command.attributes = valid_command_attributes
    @command.save!
    @command.should be_parametric
  end
  
  it "should not be parametric" do
    @command.attributes = valid_command_attributes.with(:url => "http://google.com")
    @command.save!
    @command.should_not be_parametric
  end
  
  it "should be a bookmarklet" do
    @command.attributes = valid_command_attributes.with(:url => "javascript: alert('hello');")
    @command.save!
    @command.should be_bookmarklet
  end
  
  it "should not be a bookmarklet" do
    @command.attributes = valid_command_attributes
    @command.save!
    @command.should_not be_bookmarklet
  end
  
  it "should be public" do
    @command.attributes = valid_command_attributes
    @command.save!
    @command.should be_public
    @command.should_not be_private
  end

  it "should be private" do
    @command.attributes = valid_command_attributes.with(:public => false)
    @command.save!
    @command.should be_private
    @command.should_not be_public
  end
  
  it "should update query counts"
  
  it 'option command is parametric' do
    @command.url = "http://google.com/search?q=this&v=[:v]"
    @command.save
    @command.parametric?.should be_true
  end
end

describe 'Command.parse_into_keyword_and_query: ' do
  
  it 'normal' do
    result = ["g", "that is so awesome", {:defaulted=>false, :dont_save_query=>false}]
    Command.parse_into_keyword_and_query('g that is so awesome').should == result
  end
  
  it 'sets dont_save_query flag for command_string starting with "!"' do
    result = ["g", "hide me", {:defaulted=>false, :dont_save_query=>true}]
    Command.parse_into_keyword_and_query('!g hide me').should == result
  end
  
  it 'sets dont_save_query flag for command_string with separate "!"' do
    result = ["g", "hide me", {:defaulted=>false, :dont_save_query=>true}]
    Command.parse_into_keyword_and_query('! g hide me').should == result
  end
  
  it 'sets defaulted flag' do
    result = ["g", "me default", {:defaulted=>true, :dont_save_query=>false}]
    Command.parse_into_keyword_and_query('default_to g me default').should == result
  end
  
  it "set defaulted flag and dont_save_query flag" do
    pending "can't do this for now"
    result = ["g", "me default", {:defaulted=>true, :dont_save_query=>true}]
    Command.parse_into_keyword_and_query('default_to !g me default').should == result
  end
  
  it 'handles "+" from Rails as whitespace' do
    result = ["g", "so cool", {:defaulted=>false, :dont_save_query=>false}]
    Command.parse_into_keyword_and_query('g so+cool').should == result
  end
  
  it 'handles empty command' do
    result = ["", "", {:defaulted=>false, :dont_save_query=>false}]
    Command.parse_into_keyword_and_query('').should == result
  end
  
  it 'preserves white space in command' do
    result = ["g", "i want   space", {:defaulted=>false, :dont_save_query=>false}]
    Command.parse_into_keyword_and_query('g i want   space').should == result
  end
end