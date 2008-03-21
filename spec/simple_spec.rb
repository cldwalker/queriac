class PeepCode

 def awesome?
  true
 end
 
 def screencasts
   ["a", "b", "c"]
  end
  
end

class Book; end

describe PeepCode do

  before(:each) do
    @peepcode = PeepCode.new
  end
  
  it "should be awesome" do
    @peepcode.should be_awesome
  end
  
  it "should not be a book" do
    @peepcode.should_not be_an_instance_of(Book)
  end
  
  it "should have three screencasts" do
    @peepcode.should have(3).screencasts
  end
  
end