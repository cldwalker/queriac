
class StaticController < ApplicationController
  
  def home
    @queries = Query.public.non_empty.paginate(
      :page => params[:page],
      :order => "queries.created_at DESC", 
      :include => [:command, :user]
    ) 
    @users = User.find_top_users 
  end
  
end
