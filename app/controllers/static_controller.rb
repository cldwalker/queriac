
class StaticController < ApplicationController
  
  def home
    @queries = Query.public.non_empty.find(:all, :order => "queries.created_at DESC", 
      :include => [{:user_command=>[:command, :user]}, :user], :limit=>30) 
    @users = User.find_top_users 
    @commands = Command.find(:all, :order=>'commands.created_at DESC', :limit=>3, :include=>:user)
  end
  
end
