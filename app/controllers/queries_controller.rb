class QueriesController < ApplicationController
  before_filter :load_valid_user_if_specified, :only=>:index
  before_filter :load_tags_if_specified, :only=>:index
  before_filter :set_command, :only=>:command_queries
  before_filter :store_location, :only=>[:index, :command_queries]
  before_filter :allow_breadcrumbs, :only=>[:index, :command_queries]
  before_filter :owner_required, :only => [:edit, :update, :destroy]

  def index
    
    # Possiblities..
    # /queries                  => public queries
    # /queries/tag/google       => public queries for a tag or tags
    # /zeke/g/queries           => all || public queries for a specific command
    # /zeke/queries             => all || public queries for a specific user
    # /zeke/queries/tag/google  => all || public queries for a specific user for a tag or tags
    
    pagination_params = {:order => "queries.created_at DESC", :page => params[:page], :include => [:user_command => [:user]]}
    
    if @user
      if params[:command]
        # => /zeke/g/queries
        @user_command = @user.user_commands.find_by_keyword(params[:command])
        return if user_command_is_nil?(params[:command])
        return unless command_query_is_public?
        @queries = @user_command.queries.paginate(pagination_params)
      else
        if @tags
          # => /zeke/queries/tag/google
          query_publicity = current_user? ? "any" : "publicly_queriable"
          commands = @user.user_commands.send(query_publicity).find_tagged_with(@tags.join(", "), :match_all => true, :select => [:id])
          command_ids = commands.map(&:id).join(", ")
          @queries = Query.non_empty.paginate({:conditions => ["queries.user_command_id IN (#{command_ids})"]}.merge(pagination_params)) unless command_ids.blank?
          @queries ||= [].paginate
        else
          # => /zeke/queries
          publicity = current_user? ? "any" : "public"
          @queries = @user.queries.non_empty.send(publicity).paginate(pagination_params)
        end
      end
    else
      if @tags
        # => /queries/tag/google
        
        # Rather than doing a crazy/slow join, do two queries..
        # First query gets all commands with the specified tag(s) and throws them into a string
        commands = UserCommand.publicly_queriable.find_tagged_with(@tags.join(", "), :match_all => true, :select => [:id])
        command_ids = commands.map(&:id).join(", ")
        
        # Second query gets all queries with command_ids from above..
        @queries = Query.non_empty.paginate({:conditions => ["queries.user_command_id IN (#{command_ids})"]}.merge(pagination_params)) unless command_ids.blank?
        @queries ||= [].paginate
      else
        # => /queries
        @queries = Query.non_empty.send("public").paginate(pagination_params)
      end
    end
    
    if @queries.blank? && @tags.nil?
      flash[:warning] = "Sorry, no queries matched your request."
      redirect_to home_path
      return
    end
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @queries.to_xml }
    end
  end
  
  def command_queries
    @queries = @command.queries.public.paginate(:order => "queries.created_at DESC", :page => params[:page])
    render :action=>'index'
  end

  #CRUD actions below aren't currently used
  def edit
    @query = current_user.queries.find(params[:id])
  end
  
  def update
    @query = current_user.queries.find(params[:id])

    respond_to do |format|
      if @query.update_attributes(params[:query])
        flash[:notice] = "Query updated: <b>#{@query.query_string}</b>"
        format.html { redirect_to user_home_path(current_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @query.errors.to_xml }
      end
    end
  end

  def destroy
    @query = current_user.queries.find(params[:id])
    @query.destroy

    respond_to do |format|
      flash[:notice] = "Query deleted: <b>#{@query.query_string}</b>"
      format.html { redirect_to user_home_path(current_user) }
      format.xml  { head :ok }
    end
  end
  
  protected
  def owner_required
    unless current_user?
      flash[:warning] = "You are not allowed to administer this query. "
      if logged_in?
        redirect_to user_home_path(@user)
      else
        flash[:warning] += "If it's your query, you'll need to log in to make any changes to it."
        redirect_to home_path
      end
      return
    end
  end
  
  # Don't display private queries to anyone but their commands' owners.
  def command_query_is_public?
    unless can_view_queries?
      flash[:warning] = "The user command's queries are private. "
      redirect_to public_user_command_path(@user_command)
      return false
    end
    true
  end
  
end
