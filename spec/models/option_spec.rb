require File.dirname(__FILE__) + '/../spec_helper'

describe Option do
  it 'sanitize_input: ensures keys are symbols' do
    options = [{'name'=>'type', 'option_type'=>'normal'}]
    Option.sanitize_input(options).should == options.map {|e| e.symbolize_keys}
  end
  
  it 'sanitize_input: only keeps allowed fields' do
    options = [{:name=>'type', :option_type=>'normal', :blah=>'blah'}]
    Option.sanitize_input(options).should == [{:name=>'type', :option_type=>'normal'}]
  end
  
  it 'sanitize_input: ensures a default option_type' do
    options = [{:name=>'type'}]
    Option.sanitize_input(options).should == [{:name=>'type', :option_type=>'normal'} ]
  end
  
  it 'values_list: splits on commas and ignores anything between parantheses' do
    Option.new.values_list("man, oh,man").should == %w{man oh man}
    Option.new.values_list("man (Man), oh (O),man(Man)").should == %w{man oh man}
  end
end