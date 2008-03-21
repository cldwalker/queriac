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
    STOPWORDS.should_not be_empty
    for word in STOPWORDS
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
  
  it "should allow public queries" do
    @command.attributes = valid_command_attributes
    @command.save!
    @command.should be_public_queries
  end

  it "should not allow public queries" do
    @command.attributes = valid_command_attributes.with(:public_queries => false)
    @command.save!
    @command.should_not be_public_queries
  end
  
  it "should generate a url using a simple query" do
    @command.attributes = valid_command_attributes
    @command.save!
    query = "this is a test"
    @url = @command.url_for(query)
    @url.should eql("http://google.com/search?q=this+is+a+test")
  end
  
  it "should generate a url using a more complex query" do
    @command.attributes = valid_command_attributes
    @command.save!
    query = "this/is/fucked; and crazy!"
    @url = @command.url_for(query)
    @url.should eql("http://google.com/search?q=this%2Fis%2Ffucked%3B+and+crazy%21")
  end

  it "should update tags" do
    @command.attributes = valid_command_attributes
    @command.save!
    @command.update_tags("this that other")
    @command.should have(3).tags
    @command.tags.first.name.should eql("this")
    @command.tags.last.name.should eql("other")
  end
  
  it "should generate space-delimited tag string" do
    @command.attributes = valid_command_attributes
    @command.save!
    @command.update_tags("this that other")
    @command.tag_string.should eql("this that other")
  end
  
  
  it "should update query counts"
  
  it "should count outsider queries" 

end