
class StaticController < ApplicationController
  
  def home
    @queries = Query.find_public(:all, :limit => 20, :order => "queries.created_at DESC", :include => [:command])
    @users = User.find(:all, :order => :login)
    # redirect_to current_user.home_path if logged_in?
  end
  
end
