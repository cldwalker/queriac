
class StaticController < ApplicationController
  before_filter :store_location
  before_filter :allow_breadcrumbs, :except=>:home
  def home
    @queries, @users, @latest_commands, @latest_revised_commands, @latest_user_commands = Command.get_cache(:home, :ttl=>3.minutes) do
      #PERF: excluding :include=>:user b/c it's too costly
      queries = Query.public.non_empty.find(:all, :order => "queries.created_at DESC", 
        :include => [{:user_command=>[:command, :user]}], :limit=>5)
      users = User.find_top_users
      latest_commands = Command.public.nonshortcuts.find(:all, :limit=>4, :order=>'commands.created_at DESC')
      latest_revised_commands = Command.public.find(:all, :limit=>4, :order=>'commands.revised_at DESC')
      #faster without including :user
      latest_user_commands = UserCommand.public.non_bootstrap.find(:all, :limit=>4, :order=>'user_commands.created_at DESC')
      [queries, users, latest_commands, latest_revised_commands, latest_user_commands]
    end
  end
  
  def render_page
    render :action=>params[:static_page]
  end
  
end
