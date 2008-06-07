# == Schema Information
# Schema version: 14
#
# Table name: queries
#
#  id             :integer(11)     not null, primary key
#  command_id     :string(255)     
#  query_string   :string(255)     
#  created_at     :datetime        
#  user_id        :integer(11)     
#  run_by_default :boolean(1)      
#  referrer       :text            
#

class Query < ActiveRecord::Base
  belongs_to :user_command, :foreign_key=>'command_id', :class_name=>"UserCommand"
  def command; user_command.command; end
  # belongs_to :command
  belongs_to :user
  has_many :tags, :through => :user_command

  has_finder :public, :conditions => ["user_commands.public_queries = 1"]
  has_finder :non_empty, :conditions => ["LENGTH(query_string) > 0"]
  has_finder :any

  def after_create
    if self.user_command
      self.user_command.update_query_counts 
      self.user_command.command.update_query_counts if self.user_command.command
    end
  end
  
end
