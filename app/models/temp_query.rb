class TempQuery < ActiveRecord::Base
  belongs_to :user_command, :foreign_key=>'command_id', :class_name=>"UserCommand"
  def command; user_command.command; end
  #belongs_to :command
  belongs_to :user

  has_many :tags, :through => :user_command

  has_finder :public, :include => [:user_command], :conditions => ["user_commands.public_queries = 1"]
  has_finder :non_empty, :conditions => ["LENGTH(query_string) > 0"]
  has_finder :any

  #CHANGE:
  # def after_create
  #   # self.command.update_query_counts
  #   self.user_command.update_query_counts if self.user_command
  # end
  
end
