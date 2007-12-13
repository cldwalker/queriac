class CommandsController < ApplicationController
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

    # raise params.inspect
    param_parts = params[:command].first.split(' ')
    keyword = param_parts.shift.downcase # first part of string
    query_string = param_parts.join(' ') # remainder of the string
    
    raise query_string.inspect
    
    @user = User.find_by_login(params[:login])
    # @user = User.find :first, :conditions => ['login = ?', params[:login]]

    @command = @user.commands.find_by_keyword(keyword)
    # 
    # if params[:id].match(/^[0-9]+$/)
    #   # Get command by ID
    #   @command = Command.find(params[:id], :include => [:queries, :tags], :order => "queries.created_at DESC")
    # else
      
      # raise params.inspect
      # raise CGI.escape(params[:id])
      
      # param_parts = params[:id].split(' ')
      # keyword = param_parts.shift.downcase # first part of string
      # query_string = param_parts.join(' ') # remainder of the string
      # 
      # @command = Command.find_by_keyword(keyword)
      
      # if @command.blank?
      #   # this should be in a rescue clause
      #   redirect_to new_command_path(:params => {:keyword => keyword})
      #   return
      # end

      # if @command.parametric? && query_string.empty?
      #   # Re-find the command with its tags and queries included for the 'show' view
      #   @command = Command.find_by_keyword(keyword, :include => [:queries, :tags], :order => "queries.created_at DESC")
      # 
      # elsif @command.parametric?
      if @command.parametric?
                
        @command.save_hit(query_string)
        if @command.bookmarklet?
          render :text => @command.url_for(query_string)
        else
          # raise @command.url_for(query_string)
          redirect_to @command.url_for(query_string)
        end
        return

      else
        
        if @command.bookmarklet?
          render :text => @command.url
        else
          redirect_to @command.url
        end        
        return

      end
      
    # end

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @command.to_xml }
    end
  end

  # GET /commands/new
  def new  
    @command = Command.new        
  end

  # GET /commands/1;edit
  def edit
    param_parts = params[:command].split(' ')
    keyword = param_parts.shift.downcase # first part of string
    query_string = param_parts.join(' ') # remainder of the string
    
    @user = User.find :first, :conditions => ['login = ?', params[:login]]

    @command = @user.commands.find_by_keyword(keyword)    
    # @command = Command.find(params[:id])
  end

  # POST /commands
  # POST /commands.xml
  def create
    
    if params['bookmarks_file']
      # User uploaded a bookmark file
      
      new_file = "#{RAILS_ROOT}/public/bookmark_files/#{Time.now.to_s(:ymdhms)}.html"
      
      File.open(new_file, "wb") { |f| f.write(@params['bookmarks_file'].read) }

      @commands = []
      doc = open(new_file) { |f| Hpricot(f) }
      (doc/"a").each do |a|
        unless a.attributes['shortcuturl'].blank?
          name = a.inner_html
          keyword = a.attributes['shortcuturl']        
          url = a.attributes['href']
          @commands << Command.create(
            :name => name,
            :keyword => keyword,
            :url => url, 
            :origin => "import"
          )
        end
      end

      respond_to do |format|      
          flash[:notice] = "Imported #{@commands.size} new commands from your uploaded bookmarks file."
          format.html { redirect_to commands_url }
          format.xml  { head :created, :location => command_url(@command) }
      end
            
    else
      
      # User filled out form to create single command
      @command = Command.new(params[:command])
      
      respond_to do |format|      
        if @command.save
          flash[:notice] = "New command created: <b>#{@command.name}</b>"
          format.html { redirect_to commands_url }
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
        flash[:notice] = "Command updated: <b>#{@command.name}</b>"
        format.html { redirect_to commands_url }
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
    @command = Command.find(params[:id], :include => [:queries])
    @command.queries.destroy_all
    @command.destroy

    respond_to do |format|
      flash[:notice] = "Command deleted: <b>#{@command.name}</b>"      
      format.html { redirect_to commands_url }
      format.xml  { head :ok }
    end
  end
  
end
