
class StaticController < ApplicationController
  
  def home
    @queries = Query.public.find(
      :all, 
      :limit => 30, 
      :order => "queries.created_at DESC", 
      :include => [:command, :user]
    )  
    @users = User.find(:all, :order => :login)
  end
  
end
