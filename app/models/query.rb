# == Schema Information
# Schema version: 10
#
# Table name: queries
#
#  id           :integer(11)     not null, primary key
#  command_id   :string(255)     
#  query_string :string(255)     
#  created_at   :datetime        
#

class Query < ActiveRecord::Base
  belongs_to :command
  
  def self.find_public(*args)
    with_scope(:find => {:conditions => ["commands.public_queries = 1"], :include => [:command]}) do
      self.find(*args)
    end
  end
  
end
