class CommandsController < ApplicationController
  include CommandsControllerHelper
  before_filter :login_required, :except => [:index, :execute, :show, :tagged_commands, :header_search]
  before_filter :load_valid_user, :only=>[:execute]
  before_filter :load_tags_if_specified, :only=>:tagged_commands
  before_filter :admin_required, :only=>[:edit, :update, :tag_set, :tag_add_remove, :find_by_ids]
  before_filter :set_command, :only=>[:show, :edit, :update]
  before_filter :allow_breadcrumbs, :only=>[:index, :show, :edit, :tagged_commands]
  before_filter :store_location, :only=>[:index, :show, :tagged_commands]
  before_filter :add_rss_feed, :only=>:index
  
  def header_search
    if logged_in? && params[:commit] == "Search Commands"
      redirect_to search_all_commands_path(:q=>params[:q])
    else
      redirect_to user_command_execute_path(User::PUBLIC_USER, params[:q])
    end
  end
  
  def tagged_commands
    @commands = Command.public.find_tagged_with(@tags.join(", "), :match_all => true,
      :order =>sort_param_value).paginate(index_pagination_params)
    if @commands.empty?
      flash[:warning] = "Sorry, no commands matched your request."
      redirect_to home_path
      return
    end
    render :action=>'index'
  end
  
  def find_by_ids
    @commands = Command.find(params[:ids].split(",")).paginate(index_pagination_params.dup.merge(:order=>sort_param_value))
    private_commands = @commands.reject(&:public)
    flash[:notice] = "Private commands: #{private_commands.map(&:keyword).join(', ')}" if ! private_commands.empty?
    render :action=>'index'
  end
  
  def index    
    command_chain = Command.send("public")
    command_chain = filter_command_chain_by_type(command_chain)
    @commands = command_chain.paginate(index_pagination_params.dup.merge(:order=>sort_param_value))
    
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
        command_chain = Command.any
        command_chain = filter_command_chain_by_type(command_chain)
        @commands = command_chain.advanced_search(params[:q]).paginate(index_pagination_params.merge(:order=>sort_param_value('commands.queries_count_all DESC')))
      else
        command_chain = Command.public
        command_chain = filter_command_chain_by_type(command_chain)
        @commands = command_chain.search(params[:q]).paginate(index_pagination_params.merge(:order=>sort_param_value('commands.queries_count_all DESC')))
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
    if (@user_command.private? || !@user_command.anonymous_queries?) && ! @user_command.owned_by?(current_user)
      redirect_path = user_home_path(@user)
      redirect_path << (logged_in? ? "?illegal_command=#{keyword}" : "?private_command=#{keyword}")
      redirect_to(redirect_path) and return
    end
    
    save_queries = options[:toggle_save_query] ? !@user_command.save_queries? : @user_command.save_queries?
    # Store the query in the database (or not)
    @user_command.queries.create(
      :query_string => query_string,
      :run_by_default => options[:defaulted] || false,
      :user_id => logged_in? ? current_user.id : nil,
      :referrer => request.env["HTTP_REFERER"]
    ) if save_queries
    
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
    @user_commands, @queries =  @command.cached(:show_page)
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
        @command.update_tags(params[:tags])
        flash[:notice] = "Command updated."
        format.html { redirect_to command_path(@command) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @command.errors.to_xml }
      end
    end
  end
  def tag_add_remove
    tag_add_remover {|e| Command.find_by_keyword(e)}
  end
  
  def tag_set
    tag_setter {|e| Command.find_by_keyword(e)}
  end

  def valid_sort_columns; %w{name queries_count_all created_at keyword revised_at users_count}; end
  protected
  
  def render_tag_action(tag_string, keywords, successful_commands)
    if tag_string.blank?
      flash[:warning] = "No tags specified. Please try again."
      redirect_to commands_path
    elsif successful_commands.empty?
      flash[:warning] = "Failed to find commands: #{keywords.to_sentence}"
      redirect_to commands_path
    else
      flash[:notice] = "Updated tags for commands: #{successful_commands.map(&:keyword).to_sentence}."
      redirect_back_or_default command_path(successful_commands[0])
    end
  end
  
  def filter_command_chain_by_type(command_chain)
    if Command::TYPES.map(&:to_s).include?(params[:type])
      @command_type = params[:type]
      command_chain = command_chain.send(params[:type]) 
    end
    command_chain
  end
  
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


