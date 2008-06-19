
class StaticController < ApplicationController
  before_filter :store_location
  before_filter :allow_breadcrumbs, :except=>:home
  def home
    #PERF: excluding :include=>:user b/c it's too costly
    @queries = Query.public.non_empty.find(:all, :order => "queries.created_at DESC", 
      :include => [{:user_command=>[:command, :user]}], :limit=>45)
    # keep out anonymous queries, too costly to do in db
    @queries = @queries.select {|e| !e.user_id.nil? }.slice(0,30)
    @users = User.find_top_users 
    #faster without including :user
    @user_commands = UserCommand.public.non_bootstrap.find(:all, :limit=>4, :order=>'user_commands.created_at DESC')
  end
  
end
