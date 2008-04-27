
class StaticController < ApplicationController
  
  def home
    @queries = Query.public.non_empty.paginate(
      :page => params[:page],
      :order => "queries.created_at DESC", 
      :include => [:command, :user]
    )  
    @users = User.find(:all, :conditions => ["activation_code IS NULL"], :order => :login)
    @users.reject! {|u| u.commands.count < 15 }
  end
  
end
