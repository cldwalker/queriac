
class StaticController < ApplicationController
  
  def home
    @queries = Query.public.paginate(
      :page => params[:page],
      :order => "queries.created_at DESC", 
      :include => [:command, :user]
    )  
    @users = User.find(:all, :order => :login)
  end
  
end
