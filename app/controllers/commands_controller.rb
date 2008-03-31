class CommandsController < ApplicationController

  before_filter :login_required, :except => [:index, :execute, :show]
  before_filter :load_user_from_param, :only => [:index, :execute, :show, :edit]
  before_filter :redirect_invalid_user, :only=>[:execute, :show, :edit]

  def index

    # Possiblities..
    # /commands                   => public commands
    # /commands/tag/google        => public commands for a tag or tags
    # /zeke/commands/             => all || public commands for a specific user
    # /zeke/commands/tag/google   => all || public commands for a specific user for a tag or tags

    publicity = owner? ? "any" : "public"

    @tags = params[:tag].first.gsub(" ", "+").split("+") if params[:tag]
    
    pagination_params = {:order => "commands.queries_count_all DESC", :page => params[:page], :include => [:tags]}
    
    if @tags
      if @user
        @commands = @user.commands.send(publicity).find_tagged_with(@tags.join(", "), :match_all => true, :order => "commands.queries_count_all DESC").paginate(pagination_params)
      else
        @commands = Command.send("public").find_tagged_with(@tags.join(", "), :match_all => true, :order => "commands.queries_count_all DESC").paginate(pagination_params)
      end
    else
      if @user
        @commands = @user.commands.send(publicity).paginate(pagination_params)
      else
        @commands = Command.send("public").paginate(pagination_params)
      end
    end
    
    if @commands.empty?
      flash[:warning] = "Sorry, no queries matched your request."
      redirect_to ""
      return
    end

    
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @queries.to_xml }
    end
  end
  
  def execute
    # Extract command and query string from params
    # (The join is here to bring query strings back together, as queries containing
    # slashes are broken into array elements by Rails' routing
    
    # Note: When upgrading to Rails 2, split(' ') had to be changed into split('+')
    # ..not sure why
    param_parts = params[:command].join("/").gsub(' ', '+').split('+')
    keyword = param_parts.shift.downcase # steal first word of the string
    
    # If first part of string is 'default_to', take note and use next
    # word in string as the command to execute
    if keyword == "default_to"
      keyword = param_parts.shift.downcase 
      defaulted = true
    end
    
    # Handle stealth queries (allowing for presence or absence of space following the !)
    dont_save_query = true if keyword.starts_with? "!"
    keyword = param_parts.shift.downcase if keyword == "!"
    keyword = keyword.slice(1, keyword.length-1) if keyword.starts_with? "!"
    
    # This is the remainder of the string,
    # after command has been lopped off the beginning of string
    query_string = param_parts.join(' ') 
    
    @command = @user.commands.find_by_keyword(keyword)
    
    # If command doesn't exist, route the query to the user's default command,
    # or redirect to user's home path and show options, depending on their settings.
    if @command.nil? 
      if @user.default_command?
        redirect_to @user.default_command_path(params[:command].join("/"))
      else
        redirect_to @user.home_path + "?bad_command=#{keyword}"
      end
      return
    end

    # Don't allow outsiders to run private commands
    
    if @command.private? && !owner?
      if logged_in?
       redirect_to @user.home_path + "?private_command=#{keyword}"
      else 
        redirect_to "" + "?bad_command=#{keyword}"
      end
      return
    end
    
    # Store the query in the database (or not)
    @command.queries.create(
      :query_string => query_string,
      :run_by_default => defaulted || false,
      :user_id => current_user.id,
      :referrer => request.env["HTTP_REFERER"]
    ) unless dont_save_query
    
    # Needs to be constructed if commands takes arguments
    @result = @command.parametric? ? @command.url_for(query_string) : @command.url
      
    if @command.bookmarklet?
      # Command is a Javascript bookmarklet, so rather than redirect to it,
      # we simply render it so the script that called it can use it as its source.
      render :text => @result
      
    # elsif params[:js]
      # Command is not Javascript, but is being executed in a Javascript context,
      # so convert the URL into Javascript that will redirect to the URL.
      # render :text => "document.window.location='http://shit.com';"
      
    else
      # Command is a simple URL to which we redirect
      redirect_to @result
    end

  end

  def show
    @command = @user.commands.find_by_keyword(params[:command])
    
    if @command.nil?
      flash[:warning] = "User #{@user.login} has no command with keyword '#{params[:command]}'"
      redirect_to @user.home_path
      return
    end

    publicity = owner? ? "any" : "public"
    @queries = @command.queries.send(publicity).paginate(:order => "queries.created_at DESC", :page => params[:page]) if owner? || @command.public?

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @command.to_xml }
    end
  end

  def new  
    @command = Command.new
    
    if params[:ancestor]
      @ancestor = Command.find(params[:ancestor])
      raise "You cannot duplicate a private command" unless @ancestor.public? || owner?(@ancestor)
      @command.name = @ancestor.name
      @command.keyword = @ancestor.keyword
      @command.url = @ancestor.url
      @command.description = @ancestor.description
    end
    
    # Allow user to pre-populate form.
    @command.name = params[:name] if params[:name]
    @command.keyword = params[:keyword] if params[:keyword]
    @command.url = params[:url] if params[:url]
    @command.description = params[:description] if params[:description]
  end

  def edit
    if ! owner?
      flash[:warning] = "You are not allowed to edit this command." 
      redirect_to @user.home_path
    end
    @command = current_user.commands.find_by_keyword(params[:command], :include => [:user])
  end

  def create

    # If user uploaded a bookmark file
    if params['bookmarks_file']
      
      new_file = "#{RAILS_ROOT}/public/bookmark_files/#{Time.now.to_s(:ymdhms)}.html"  
      unless params['bookmarks_file'].blank?
        File.open(new_file, "wb") { |f| f.write(params['bookmarks_file'].read) }
        valid_commands, invalid_commands = Command.create_commands_for_user_from_bookmark_file(current_user, new_file)
      end

      respond_to do |format|
          if params['bookmarks_file'].blank?
            flash[:warning] = 'Not a valid bookmark file, try again.'
            new
            format.html { render :action => "new" }
          else
            flash[:notice] = "Imported #{valid_commands.size} of #{(valid_commands + invalid_commands).size} commands from your uploaded bookmarks file."
            format.html { redirect_to current_user.home_path }
          end
      end
            
    else
      
      # User filled out form to create single command
      
      @command = current_user.commands.new(params[:command])
      @command.user = current_user
      
      respond_to do |format|      
        if @command.save
          @command.update_tags(params[:tags])
          flash[:notice] = "New command created: <b><a href='#{@command.show_path}'>#{@command.name}</a></b>"
          format.html { redirect_to current_user.home_path }
          format.xml  { head :created, :location => command_url(@command) }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @command.errors.to_xml }
        end
      end
      
    end      
  end

  def update
    @command = Command.find(params[:id])

    respond_to do |format|
      if @command.update_attributes(params[:command])
        @command.update_tags(params[:tags])
        flash[:notice] = "Command updated: <b><a href='#{@command.show_path}'>#{@command.name}</a></b>"
        format.html { redirect_to current_user.home_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @command.errors.to_xml }
      end
    end
  end

  def destroy
    @command = current_user.commands.find_by_keyword(params[:command], :include => [:queries])
    @command.queries.destroy_all
    @command.destroy

    respond_to do |format|
      flash[:notice] = "Command deleted: <b>#{@command.name}</b>"      
      format.html { redirect_to current_user.home_path }
      format.xml  { head :ok }
    end
  end
  
end
