# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/rails'

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures'

  # You can declare fixtures for each behaviour like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so here, like so ...
  #
  #   config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  def valid_user_attributes
    {
      :login => "bozo",
      :email => "bozo@email.com",
      :password  => "partyfavors",
      :password_confirmation  => "partyfavors"
    }
  end
  
  
  def generate_random_alphanumeric(len=8)
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      string = ""
      1.upto(len) { |i| string << chars[rand(chars.size-1)] }
      return string
  end
  
  def random_valid_command_attributes
    seed = generate_random_alphanumeric(3)
    {:url=>"http://#{seed}.com/(q)", :keyword=>seed, :name=>"name for #{seed}"}
  end
  
  def random_valid_user_attributes
    num = rand(10000)
    {:login=>"bozo_#{num}", :email=>"bozo_#{num}@email.com", :password=>'partyfavors', :password_confirmation=>'partyfavors'}
  end
  
  #should use mocks for create_* once controller specs focus only on controller logic
  def create_user(hash={})
    User.create(random_valid_user_attributes.merge(hash))
  end
  
  def create_command(hash={})
    Command.create(random_valid_command_attributes.merge(hash))
  end
  
  def login_user(hash={})
    user = hash.is_a?(User) ? hash : create_user(hash)
    @controller.should_receive(:login_required).and_return(true)
    @controller.stub!(:current_user).and_return(user)
    user
  end
  
  def current_user; @controller.current_user; end
  
end

##
# rSpec Hash additions.
#
# From 
#   * http://wincent.com/knowledge-base/Fixtures_considered_harmful%3F
#   * Neil Rahilly

class Hash

  ##
  # Filter keys out of a Hash.
  #
  #   { :a => 1, :b => 2, :c => 3 }.except(:a)
  #   => { :b => 2, :c => 3 }

  def except(*keys)
    self.reject { |k,v| keys.include?(k || k.to_sym) }
  end

  ##
  # Override some keys.
  #
  #   { :a => 1, :b => 2, :c => 3 }.with(:a => 4)
  #   => { :a => 4, :b => 2, :c => 3 }
  
  def with(overrides = {})
    self.merge overrides
  end

  ##
  # Returns a Hash with only the pairs identified by +keys+.
  #
  #   { :a => 1, :b => 2, :c => 3 }.only(:a)
  #   => { :a => 1 }
  
  def only(*keys)
    self.reject { |k,v| !keys.include?(k || k.to_sym) }
  end

end
