class CommandsController < ApplicationController

  before_filter :login_required, :except => [:execute, :show]
  before_filter :load_user, :only => [:index, :execute, :show, :edit]

  def index
    
    publicity = owner? ? "any" : "public"
    
    if params[:tag]
      @tag = params[:tag]
      @commands = @user.commands.find_tagged_with(@tag.split(" ").join(", "), :match_all => true, :order => "commands.keyword")
    else
      @commands = @user.commands.send(publicity).paginate({
        :order => "commands.keyword ASC", 
        :page => params[:page],
        :include => [:tags]
      })
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
    param_parts = params[:command].join("/").split(' ')
    keyword = param_parts.shift.downcase # steal first word of the string
    
    # If first part of string is 'default_to', take note and use next
    # word in string as the command to execute
    if keyword == "default_to"
      keyword = param_parts.shift.downcase 
      defaulted = true
    end
    
    query_string = param_parts.join(' ') # remainder of the string
    
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
      render :text => "This command (#{@command.keyword}) is not shared by this user (#{@user.login})."
      return
    end
    
    # Store the query in the database
    @command.queries.create(
      :query_string => query_string,
      :run_by_default => defaulted || false,
      :user_id => current_user.id
    )
    
    # Needs to be constructed if commands takes arguments
    @result = @command.parametric? ? @command.url_for(query_string) : @command.url
      
    if @command.bookmarklet?
      # Command is a Javascript bookmarklet, so rather than redirect to it,
      # we simply render it so the script that called it can use it as its source.
      render :text => @result
      
    # elsif params["js"]
      # Command is not Javascript, but is being executed in a Javascript context,
      # so convert the URL into a javascript that will redirect to the URL.
      # render :text => "alert(#{@yield})"
      
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

    @queries = @command.queries.paginate(:order => "queries.created_at DESC", :page => params[:page]) if owner? || @command.public?

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @command.to_xml }
    end
  end

  def new  
    @command = Command.new
    
    if params[:ancestor]
      @ancestor = Command.find(params[:ancestor])
      @command.name = @ancestor.name
      @command.keyword = @ancestor.keyword
      @command.url = @ancestor.url
      @command.description = @ancestor.description
    elsif params[:keyword]
      @command.keyword = params[:keyword]
    end
    
  end

  def edit
    raise "You are not allowed to edit this command." unless owner?
    @command = current_user.commands.find_by_keyword(params[:command], :include => [:user])
  end

  def create

    # If user uploaded a bookmark file
    if params['bookmarks_file']
      
      new_file = "#{RAILS_ROOT}/public/bookmark_files/#{Time.now.to_s(:ymdhms)}.html"
      
      File.open(new_file, "wb") { |f| f.write(@params['bookmarks_file'].read) }

      @commands = []
      doc = open(new_file) { |f| Hpricot(f) }
      (doc/"a").each do |a|
        unless a.attributes['shortcuturl'].blank?
          name = a.inner_html
          keyword = a.attributes['shortcuturl']
          url = a.attributes['href']
          @commands << current_user.commands.create(
            :name => name,
            :keyword => keyword,
            :url => url, 
            :origin => "import"
          )
        end
      end

      respond_to do |format|      
          flash[:notice] = "Imported #{@commands.size} new commands from your uploaded bookmarks file."
          format.html { redirect_to current_user.home_path }
      end
            
    else
      
      # User filled out form to create single command
      
      @command = current_user.commands.new(params[:command])
      @command.user = current_user
      
      respond_to do |format|      
        if @command.save
          @command.tag_with(params[:tags])
          flash[:notice] = "New command created: <b>#{@command.name}</b>"
          format.html { redirect_to "/#{current_user.login}" }
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
        flash[:notice] = "Command updated: <b>#{@command.name}</b>"
        format.html { redirect_to "/#{current_user.login}" }
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
