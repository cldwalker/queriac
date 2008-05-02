# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require File.expand_path(File.dirname(__FILE__) + "/create_spec_helper")
require 'spec/rails'

Spec::Runner.configure do |config|
  include CreateSpecHelper
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures'

  #@controller of each example is reset so no need to logout users
  def login_user(hash={})
    user = hash.is_a?(User) ? hash : create_user(hash)
    @controller.stub!(:login_required).and_return(true)
    @controller.stub!(:current_user).and_return(user)
    user
  end
  
  #using before(:all) to minimize db calls (speed up tests) until objects can be mocked
  #coupling examples to the same test object is a no-no: http://rspec.info/documentation/before_and_after.html
  def setup_login_user
    before(:all) { @user = create_user }
    before(:each) { login_user(@user)}
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

module ActiveRecord
  class Base
    def self.find_last
      find(:first, :order=>'id DESC')
    end
  end
end