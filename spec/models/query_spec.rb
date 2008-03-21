require File.dirname(__FILE__) + '/../spec_helper'


describe Query do
  
  before(:each) do
    @query = Query.new
  end

  it "should be valid" do
    @query.should be_valid
  end
  
  it "should update query counts after creation"

end