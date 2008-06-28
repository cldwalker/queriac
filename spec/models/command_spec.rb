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
  
  it "should update query counts"
  
  it "should parse query options" do
    query_string = "--L -view normal -type = cool -r='one two' -q 'three' still here"
    expected_options = {'L'=>true, 'view'=>'normal', 'type'=>'cool', 'r'=>'one two', 'q'=>'three'}
    @command.parse_query_options(query_string).should == expected_options
    query_string.should =~ /^\s*still here$/
  end
  
  it 'no option parsing when query starts with option -off' do
    query_string = '-off -type cool more still'
    original_query_string = query_string.dup
    @command.parse_query_options(query_string).should == {}
    query_string.should_not == original_query_string
  end
  
  it "no option parsing when query doesn't start with '-'" do
    query_string = 'some args -late option'
    @command.parse_query_options(query_string).should == {}
    query_string.should == query_string
  end
  
  it 'option command is parametric' do
    @command.url = "http://google.com/search?q=this&v=[:v]"
    @command.save
    @command.parametric?.should be_true
  end
end

describe 'url_for: ' do
  before(:each) {@command = Command.new}
  
  it 'normal' do
    @command.url = "http://google.com/search?q=(q)"
    expected_url = "http://google.com/search?q=this+is+a+test"
    @command.url_for('this is a test').should == expected_url
  end
  
  it 'option command with option' do
    @command.url = "http://google.com/search?q=(q)&type=[:type=normal]"
    expected_url = "http://google.com/search?q=yep&type=cool"
    @command.url_for('-type cool yep').should == expected_url
  end
  
  it 'option command with multiple options' do
    @command.url = "http://google.com/search?q=(q)&type=[:type=normal]&view=[:view]"
    expected_url = "http://google.com/search?q=yep&type=cool&view=long"
    @command.url_for('-type cool -view long yep').should == expected_url
  end
  
  it 'option command using default' do
    @command.url = "http://google.com/search?q=(q)&type=[:type=normal]"
    expected_url = "http://google.com/search?q=yep&type=normal"
    @command.url_for('yep').should == expected_url
  end
    
  it 'option command with no option or default' do
    @command.url = "http://google.com/search?q=(q)&type=[:type]"
    expected_url = "http://google.com/search?q=yep&type="
    @command.url_for('yep').should == expected_url
  end
  
  it 'option command with default having spaces' do
    @command.url = "http://google.com/search?q=(q)&type=[:type=long type sheesh]"
    expected_url = "http://google.com/search?q=yep&type=long+type+sheesh"
    @command.url_for('yep').should == expected_url
  end
  
  it 'position command with multiple positions' do
    @command.url = "http://queri.ac/[:1]/user_commands/tag/[:2]"
    expected_url = "http://queri.ac/ghorner/user_commands/tag/google"
    @command.url_for('ghorner google').should == expected_url
  end
  
  it 'position command with repeat positions' do
    @command.url = "http://google.com/search?q=[:2]&view=[:1]&type=[:1]"
    expected_url = "http://google.com/search?q=this&view=normal&type=normal"
    @command.url_for('normal this').should == expected_url
  end
  
  it 'position + option command' do
    @command.url = "http://google.com/search?q=[:2]&view=[:1]&type=[:type]"
    expected_url = "http://google.com/search?q=dodo&view=normal&type=cool"
    @command.url_for('-type cool normal dodo').should == expected_url
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