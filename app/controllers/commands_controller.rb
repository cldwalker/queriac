class CommandsController < ApplicationController

  before_filter :login_required, :except => [:index, :execute, :show]
  before_filter :load_valid_user, :only=>[:execute]
  # before_filter :load_valid_user_if_specified, :only=>:index
  # before_filter :load_tags_if_specified, :only=>:index
  before_filter :admin_required, :only=>[:edit, :update]
  before_filter :set_command, :only=>[:show, :edit, :update]
  before_filter :allow_breadcrumbs, :only=>[:index, :show, :edit]
  before_filter :store_location, :only=>[:index, :show]
  before_filter :add_rss_feed, :only=>:index
  
  # Possiblities..
  # /commands                   => public commands
  def index
    pagination_params = index_pagination_params.dup
    
    #TODO: enable tag + user listings of commands    
    # publicity = current_user? ? "any" : "public"
    # if @tags
    #   if @user
    #     @commands = @user.commands.send(publicity).find_tagged_with(@tags.join(", "), :match_all => true, :order => "commands.queries_count_all DESC").paginate(pagination_params)
    #   else
    #     @commands = Command.send("public").find_tagged_with(@tags.join(", "), :match_all => true, :order => "user_commands.queries_count DESC").paginate(pagination_params)
    #   end
    # else
    # end
    # if @user
    #   @commands = @user.commands.send(publicity).paginate(pagination_params)
    # end
    
    @commands = Command.send("public").paginate(pagination_params.merge(:order=>sort_param_value))
    
    if @commands.empty?
      flash[:warning] = "Sorry, no commands matched your request."
      redirect_to home_path
      return
    end
        
    respond_to do |format|
      format.html
      format.rss
      format.xml { render :xml => @commands.to_xml }
    end
  end
  
  def search_all
    if params[:q].blank?
      flash[:warning] = "Your search is empty. Try again."
      @commands = [].paginate
    else
      if admin?
        @commands = Command.any.advanced_search(params[:q]).paginate(index_pagination_params.merge(:order=>sort_param_value('commands.queries_count_all DESC')))
      else
        @commands = Command.public.search(params[:q]).paginate(index_pagination_params.merge(:order=>sort_param_value('commands.queries_count_all DESC')))
      end
    end
    render :action => 'index'
  end

  def execute
    if params[:command] == ['search_form'] && params[:search_command]
      command_string = params[:search_command]
    else
      #here because Rails routing splits urls by '/' into an array
      command_string = params[:command].join("/")
    end
    keyword, query_string, options = Command.parse_into_keyword_and_query(command_string)
    
    @user_command = @user.user_commands.find_by_keyword(keyword)
    
    # If command doesn't exist, route the query to the user's default command,
    # or redirect to user's home path and show options, depending on their settings.
    if @user_command.nil?
      if @user.default_command?
        redirect_to user_default_command_path(@user, command_string)
      else
        redirect_to user_home_path(@user) + "?bad_command=#{keyword}&arguments=#{query_string}"
      end
      return
    end

    # Don't allow outsiders to run private commands  
    if (@user_command.private? || !@user_command.allow_anonymous_queries?) && ! @user_command.owned_by?(current_user)
      redirect_path = user_home_path(@user)
      redirect_path << (logged_in? ? "?illegal_command=#{keyword}" : "?private_command=#{keyword}")
      redirect_to(redirect_path) and return
    end
    
    # Store the query in the database (or not)
    @user_command.queries.create(
      :query_string => query_string,
      :run_by_default => options[:defaulted] || false,
      :user_id => logged_in? ? current_user.id : nil,
      :referrer => request.env["HTTP_REFERER"]
    ) unless options[:dont_save_query]
    
    #parse alias js symbols before query parsing since js symbols do appear in some urls
    if params[:js] && !@user_command.bookmarklet?
      query_string.gsub!(/(#{Command::JAVASCRIPT_SYMBOLS.to_a.flatten.join('|')})/) do
        Command::JAVASCRIPT_SYMBOLS.invert[$1] || $1
      end
    end
    
    # Needs to be constructed if commands takes arguments
    url_for_options = {:auto_aliasing=>admin?} #, :url_unencode=>(params[:js] && !@user_command.bookmarklet?)}
    @result = @user_command.parametric? ? @user_command.url_for(query_string, url_for_options) : @user_command.url
    
    # Command is a Javascript bookmarklet, so rather than redirect to it,
    # we simply render it so the script that called it can use it as its source.
    if @user_command.bookmarklet?
      render :text => @result
      
    #work in progress
    #convert non-js command to js that redirects to url
    elsif params[:js] #&& @user_command.parametric?
      result = Command.convert_to_javascript(@result)
      render :text=>result
    elsif @user_command.http_post?
      @form_action, form_query = @result.split("?")
      @form_inputs = form_query.split("&").map {|e| e.split("=")} rescue []
      @no_js = true
      render :action=>"execute_post"
    elsif @user_command.query_options['test']
      @no_js = true
      @query_string = query_string
      render :action=>'test_command'
    elsif @user_command.query_options['help']
      redirect_to help_public_user_command_path(@user_command)
    else
      # Command is a simple URL to which we redirect
      redirect_to @result
    end

  end

  #desired behavior for private queries is just a sidebar?
  def show
    @user_commands = @command.user_commands.find(:all, :limit=>5, :order=>'queries_count DESC', :include=>:user)
    @queries = @command.queries.public.find(:all, :order => "queries.created_at DESC", :limit=>30)
    respond_to do |format|
      format.html
      format.xml  { render :xml => @command.to_xml }
    end
  end

  def edit
  end
  
  def update
    respond_to do |format|
      if @command.update_attributes(params[:command])
        flash[:notice] = "Command updated."
        format.html { redirect_to command_path(@command) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @command.errors.to_xml }
      end
    end
  end

  def valid_sort_columns; %w{name queries_count_all created_at keyword}; end
  protected
  
  def sort_param_value(default_sort = 'commands.created_at DESC')
    general_sort_param_value('commands', valid_sort_columns, default_sort)
  end
  
  def index_pagination_params
    #{:order => "commands.queries_count_all DESC", :page => params[:page], :include => [:tags]}
    {:page => params[:page], :include=>:user}
  end

end

__END__

##Creation + destruction of commands purposely disabled

# def new  
#   @command = Command.new    
#   # Allow user to pre-populate form.
#   @command.attributes = params.slice(:name, :keyword, :url, :description)
# end

# def create    
#   @command = current_user.commands.new(params[:command])
#   
#   respond_to do |format|      
#     if @command.save
#       @command.update_tags(params[:tags])
#       flash[:notice] = "New command created: <b><a href='#{command_path(@command)}'>#{@command.name}</a></b>"
#       format.html { redirect_to user_home_path(current_user) }
#       format.xml  { head :created, :location => command_url(@command) }
#     else
#       format.html { render :action => "new" }
#       format.xml  { render :xml => @command.errors.to_xml }
#     end
#   end      
# end

# def destroy
#   @command.destroy
# 
#   respond_to do |format|
#     flash[:notice] = "Command deleted: <b>#{@command.name}</b>"      
#     format.html { redirect_to user_home_path(current_user) }
#     format.xml  { head :ok }
#   end
# end


