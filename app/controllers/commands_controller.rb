class CommandsController < ApplicationController

  before_filter :login_required, :except => [ :show ]

  # GET /commands
  # GET /commands.xml
  def index
    
    @commands = Command.find(:all, :order => "commands.kind, commands.name", :include => [:queries])
    
    @recent_queries = Query.find(:all, :limit => 15, :order => "queries.created_at", :include => [:command])

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @commands.to_xml }
    end
  end

  # GET /commands/1
  # GET /commands/1.xml
  def show
    
    
    raise params[:command].to_yaml
    
    @user = (logged_in? && current_user.login==params[:login]) ? current_user : User.find_by_login(params[:login])

    # Catch instances of /user/keyword/view
    if params[:command][1] == "view"
      keyword = "view"
      query_string = params[:command][0]
    else
      param_parts = params[:command].first.split(' ')
      keyword = param_parts.shift.downcase # first part of string
      query_string = param_parts.join(' ') # remainder of the string
    end

    case keyword
    when "new"
      redirect_to new_command_path
      
    when "edit"
      # Show a form to edit the command

      # URLs that lead here:
      # /user/keyword edit
      # /user/keyword/edit
      begin
        @command = @user.commands.find_by_keyword(query_string)
        redirect_to "/#{@user.login}/#{@command.keyword}/edit"
      rescue
        flash[:warning] = "Command '#{query_string}' not found!"
        redirect_to @user.home_path
      end

      return
      
    when "view"
      # Show a page of stats/info for this command.
      
      # URLs that lead here:
      # /user/keyword view
      # /user/keyword/view      
      @command = @user.commands.find_by_keyword(query_string, :include => [:queries, :tags], :order => "queries.created_at DESC")
      respond_to do |format|
        format.html # show.rhtml
        format.xml  { render :xml => @command.to_xml }
      end  
      
    else
      # Not editing or viewing, so execute the requested command
      
      @command = @user.commands.find_by_keyword(keyword)
      
      if @command.nil?
        # Eventually, route the query through the user's default command
        # But for now..
        render :text => "Command not found."
        return
      end

      # Store the query in the database
      @command.save_query(query_string)
      
      # Needs to be constructed if commands takes arguments
      @yield = @command.parametric? ? @command.url_for(query_string) : @command.url
        
      if @command.bookmarklet?
        # Command is a Javascript bookmarklet, so rather than redirect to it, we
        # we simply render it so the script that called it can use it as its source.
        render :text => @yield
        
      elsif params["js"]
        # Command is not Javascript, but is being executed in a Javascript context,
        # so convert the URL into a javascript that will redirect to the URL.
        render :text => "alert(#{@yield})"
        
      else
        # Command is a simple URL to which we redirect
        redirect_to @yield
        
      end
      
    end
 
  end

  # GET /commands/new
  def new  
    @command = Command.new
    
    if params[:ancestor]
      @ancestor = Command.find(params[:ancestor])
      @command.name = @ancestor.name
      @command.keyword = @ancestor.keyword
      @command.url = @ancestor.url
      @command.description = @ancestor.description
    end
    
  end

  # GET /commands/1;edit
  def edit
    @user = User.find_by_login(params[:login])
    raise "You are not allowed to edit this command." if @user != current_user
    @command = current_user.commands.find_by_keyword(params[:command], :include => [:user])
  end

  # POST /commands
  # POST /commands.xml
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

  # PUT /commands/1
  # PUT /commands/1.xml
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

  # DELETE /commands/1
  # DELETE /commands/1.xml
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
