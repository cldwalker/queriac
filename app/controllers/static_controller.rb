
class StaticController < ApplicationController
  
  def home
    @queries = Query.public.non_empty.find(:all, :order => "queries.created_at DESC", 
      :include => [{:user_command=>[:command, :user]}, :user], :limit=>45)
    # keep out anonymous queries, too costly to do in db
    @queries = @queries.select {|e| !e.user_id.nil? }.slice(0,30)
    @users = User.find_top_users 
    @commands = Command.public.find(:all, :order=>'commands.created_at DESC', :limit=>3, :include=>:user)
  end
  
end
