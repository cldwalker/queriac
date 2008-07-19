require File.dirname(__FILE__) + '/../spec_helper'

describe 'url_for: ' do
  before(:each) {@command = Command.new}
  
  it 'simple query' do
    @command.url = "http://google.com/search?q=(q)"
    expected_url = "http://google.com/search?q=this+is+a+test"
    @command.url_for('this is a test').should == expected_url
  end
  
  it "should generate a url using a more complex query" do
    @command.url = "http://google.com/search?q=(q)"
    query = "this/is/fucked; and crazy!"
    @url = @command.url_for(query)
    @url.should eql("http://google.com/search?q=this%2Fis%2Ffucked%3B+and+crazy%21")
  end
  
  it 'basic option' do
    @command.url_options = [{:name=>'type'}]
    @command.url = "http://google.com/search?q=(q)&type=[:type]"
    expected_url = "http://google.com/search?q=yep&type=cool"
    @command.url_for('-type cool yep').should == expected_url
  end
  
  it 'multiple options' do
    @command.url_options = [{:name=>'type'}, {:name=>'view'}]
    @command.url = "http://google.com/search?q=(q)&type=[:type]&view=[:view]"
    expected_url = "http://google.com/search?q=yep&type=cool&view=long"
    @command.url_for('-type cool -view long yep').should == expected_url
  end
  
  it 'option using default' do
    @command.url_options = [{:name=>'type', :default=>'normal'}]
    @command.url = "http://google.com/search?q=(q)&type=[:type]"
    expected_url = "http://google.com/search?q=yep&type=normal"
    @command.url_for('yep').should == expected_url
  end
    
  it 'option using alias' do
    @command.url_options = [{:name=>'type', :alias=>'t'}]
    @command.url = "http://google.com/search?q=(q)&type=[:type]"
    expected_url = "http://google.com/search?q=yep&type=normal"
    @command.url_for('-t normal yep').should == expected_url
  end
  
  it 'boolean option set true' do
    @command.url_options = [{:name=>'type', :option_type=>'boolean', :true_value=>'whoop', :false_value=>'ok'}]
    @command.url = "http://google.com/search?q=(q)&type=[:type]"
    expected_url = "http://google.com/search?q=yep&type=whoop"
    @command.url_for('-type yep').should == expected_url
  end
  
  it 'boolean option left false' do
    @command.url_options = [{:name=>'type', :option_type=>'boolean', :true_value=>'whoop', :false_value=>'ok'}]
    @command.url = "http://google.com/search?q=(q)&type=[:type]"
    expected_url = "http://google.com/search?q=yep&type=ok"
    @command.url_for('yep').should == expected_url
  end
  
  it 'enumerated option given an allowed value' do
    @command.url_options = [{:name=>'type', :option_type=>'enumerated', :values=>'stupid, smart, smartass'}]
    @command.url = "http://google.com/search?q=(q)&type=[:type]"
    expected_url = "http://google.com/search?q=yep&type=stupid"
    @command.url_for('-type stupid yep').should == expected_url
  end
   
  it 'enumerated option given an invalid value uses default' do
    @command.url_options = [{:name=>'type', :option_type=>'enumerated', :values=>'stupid, smart, smartass', :default=>'smartass'}]
    @command.url = "http://google.com/search?q=(q)&type=[:type]"
    expected_url = "http://google.com/search?q=yep&type=smartass"
    @command.url_for('-type retarded yep').should == expected_url
  end
  
  it "command doesn't use its option" do
    @command.url_options = [{:name=>'type'}]
    @command.url = "http://google.com/search?q=(q)&type=[:type]"
    expected_url = "http://google.com/search?q=yep&type="
    @command.url_for('yep').should == expected_url
  end
  
  it 'argument with default' do
    @command.url_options = [{:name=>'1'}, {:name=>'2', :default=>'google'}]
    @command.url = "http://queri.ac/[:1]/user_commands/tag/[:2]"
    expected_url = "http://queri.ac/ghorner/user_commands/tag/google"
    @command.url_for('ghorner').should == expected_url
  end
  
  it 'multiple arguments' do
    @command.url_options = [{:name=>'1'}, {:name=>'2'}]
    @command.url = "http://queri.ac/[:1]/user_commands/tag/[:2]"
    expected_url = "http://queri.ac/ghorner/user_commands/tag/google"
    @command.url_for('ghorner google').should == expected_url
  end
  
  it 'argument in url multiple times' do
    @command.url_options = [{:name=>'1'}, {:name=>'2'}]
    @command.url = "http://google.com/search?q=[:2]&view=[:1]&type=[:1]"
    expected_url = "http://google.com/search?q=this&view=normal&type=normal"
    @command.url_for('normal this').should == expected_url
  end
  
  it 'arguments and options combined' do
    @command.url_options = [{:name=>'2'}, {:name=>'1'}, {:name=>'type'}]
    @command.url = "http://google.com/search?q=[:2]&view=[:1]&type=[:type]"
    expected_url = "http://google.com/search?q=dodo&view=normal&type=cool"
    @command.url_for('-type cool normal dodo').should == expected_url
  end
  
end

describe 'parse_query_options: ' do
  before(:each) { @command = Command.new }
  
  it "should parse query options" do
    query_string = "-L -view normal -type = cool -r='one two' -q 'three' still here"
    expected_options = {'L'=>true, 'view'=>'normal', 'type'=>'cool', 'r'=>'one two', 'q'=>'three'}
    @command.url_options = [{:name=>'L', :option_type=>'boolean'}]
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
end

describe 'misc actions' do
  before(:each) { @command = Command.new }
  
  it 'fetch_url_option: returns Option object' do
    @command.url_options = [{:name=>'whoop'}]
    option = @command.fetch_url_option('whoop')
    option.should be_an_instance_of(Option)
    option.name.should == 'whoop'
  end
  
  it 'fetch_url_option: returns nil for nonexistent option' do
    @command.url_options = [{:name=>'whoop'}]
    @command.fetch_url_option('bling').should be_nil
  end
  
  it 'options_from_url: returns array of option names' do
    @command.options_from_url("http://google.com/search?q=(q)&type=[:type]").should == ['type']
  end
  
  it 'options_from_url: returns empty array for optionless url' do
    @command.options_from_url("http://google.com/search?q=(q)").should == []
  end
  
  it 'options_from_url: should only return one of any option' do
    @command.options_from_url("http://google.com/search?q=(q)&type=[:type]&blah=[:type]").should == ['type']
  end
  
  it 'url_options=: sanitizes input' do
    @command.url_options = [{'name'=>'type'}]
    @command.url_options = [{:name=>'type'}]
  end
  
  it 'url_options: should return [] when value actually nil' do
    @command[:url_options].should be_nil
    @command.url_options.should == []
  end
  
  it 'url_options=: sets empty array to nil' do
    @command.url_options = []
    @command[:url_options].should be_nil
  end
  
  it 'validate_url_options: url and url_options need to in sync' do
    @command.url_options = [{'name'=>'type'}]
    @command.url = "http://google.com/search?q=(q)&num=[:num]"
    @command.validate_url_options
    @command.errors.full_messages[0].include?("don't match").should be_true
  end
  
  it 'validate_url_options: option names and aliases need to be unique'
  it 'validate_url_options: option field lengths have a maximum length'
  it 'ordered_url_options: returns order of options based on url'
end