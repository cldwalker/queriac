# == Schema Information
# Schema version: 12
#
# Table name: queries
#
#  id             :integer(11)     not null, primary key
#  command_id     :string(255)     
#  query_string   :string(255)     
#  created_at     :datetime        
#  user_id        :integer(11)     
#  run_by_default :boolean(1)      
#

class Query < ActiveRecord::Base
  belongs_to :command
  belongs_to :user

  has_finder :public, :conditions => ["commands.public_queries = 1"]

  def after_create
    self.command.update_query_counts
  end
  
end
