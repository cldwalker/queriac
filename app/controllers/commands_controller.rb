class CommandsController < ApplicationController

  before_filter :login_required, :except => [:index, :execute, :show]
  before_filter :load_valid_user, :except=>[:new, :create, :update, :copy_yubnub, :tag_set, :tag_add_remove]
  #remaining filters dependent on load_valid_user
  before_filter :permission_required_for_user, :only=>[:edit, :destroy, :search]
  #double check this filter if changing method names ie show->display
  before_filter :load_command_by_user_and_keyword, :only=>[:show, :edit, :destroy]
  
  #TODO: verify :method => :delete, :only => :destroy

  def index

    # Possiblities..
    # /commands                   => public commands
    # /commands/tag/google        => public commands for a tag or tags
    # /zeke/commands/             => all || public commands for a specific user
    # /zeke/commands/tag/google   => all || public commands for a specific user for a tag or tags

    publicity = owner? ? "any" : "public"

    if params[:tag]
      if params[:tag].first
        @tags = params[:tag].first.gsub(" ", "+").split("+") 
      #handles /:user/commands/tag case
      else
        flash[:warning] = 'No tag was specified. Please try again'
        redirect_to commands_path
        return
      end
    end
    
    pagination_params = index_pagination_params.dup
    
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
      flash[:warning] = "Sorry, no commands matched your request."
      redirect_to ""
      return
    end

    
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @commands.to_xml }
    end
  end
  
  def search
    if params[:q].blank?
      flash[:warning] = "Your search is empty. Try again."
      @commands = [].paginate
    else
      all_commands = @user.commands.find(:all, :conditions=>["keyword REGEXP ? OR url REGEXP ?", params[:q], params[:q]])
      @commands = all_commands.paginate(index_pagination_params)
    end
    render :action=>'index'
  end
  
  def tag_add_remove
    keywords, tag_string = parse_tag_input
    
    successful_commands = []
    unless tag_string.blank?
      #TODO: should move \w+ to a validation regex constant
      remove_list, add_list = tag_string.scan(/-?\w+/).partition {|e| e[0,1] == '-' }
      remove_list.map! {|e| e[1..-1]}
      keywords.each do |n| 
        if (cmd = current_user.commands.find_by_keyword(n))
          cmd.tag_list.add(add_list)
          cmd.tag_list.remove(remove_list)
          cmd.save
          successful_commands << cmd
        end
      end
    end
    render_tag_action(tag_string, keywords, successful_commands)
  end
  
  def tag_set
    edited_commands = []
    keywords, tag_string = parse_tag_input
    unless tag_string.blank?
      keywords.each do |n| 
        if (cmd = current_user.commands.find_by_keyword(n))
          cmd.update_tags(tag_string)
          edited_commands << cmd
        end
      end
    end
    render_tag_action(tag_string, keywords, edited_commands)
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
      redirect_path = @user.home_path
      redirect_path << (logged_in? ? "?illegal_command=#{keyword}" : "?private_command=#{keyword}")
      redirect_to(redirect_path) and return
    end
    
    # Store the query in the database (or not)
    @command.queries.create(
      :query_string => query_string,
      :run_by_default => defaulted || false,
      :user_id => logged_in? ? current_user.id : nil,
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

  #desired behavior for private queries is just a sidebar?
  def show
    if @command.private? && !owner?
      flash[:warning] = "Sorry, the command '#{params[:command]}' is private for #{@user.login}."
      redirect_to @user.home_path
      return
    end

    #FIXME: conditionals should match ones in the template
    publicity = owner? ? "any" : "public"
    @queries = @command.queries.send(publicity).paginate(:order => "queries.created_at DESC", :page => params[:page]) if owner? || @command.public?

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @command.to_xml }
    end
  end

  def copy_yubnub_command
    #keyword regex is strict for now, should find out what is an acceptable yubnub command
    if params[:keyword] && (keyword = params[:keyword].scan(/^\w+/).first)
      begin
        if (doc = Hpricot(open("http://yubnub.org/kernel/man?args=#{keyword}")))
          if (url = (doc/"span.muted")[0].inner_html)
            new_params = {:action=>'new', :keyword=>keyword, :url=>url}
            description = (doc/"pre").first.inner_html rescue nil
            new_params.merge!(:description=>description) if description
            redirect_to new_params #{:action=>'new'}.merge(new_params)
            return
          end
        end
      rescue
        flash[:warning] = "Failed to parse yubnub keyword '#{params[:keyword]}'"
        redirect_back_or_default current_user.home_path
        return
      end
      flash[:warning] = "Failed to parse yubnub keyword '#{params[:keyword]}'"
    else
      flash[:warning] = "The keyword '#{params[:keyword]}' is not a valid keyword. Please try again."      
    end
    redirect_back_or_default current_user.home_path
  end
  
  def new  
    @command = Command.new
    
    if params[:ancestor]
      @ancestor = Command.find(params[:ancestor])
      unless @ancestor.public? || (current_user == @ancestor.user)
        flash[:warning] = "You cannot duplicate a private command." 
        redirect_back_or_default ''
      end
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
            @command = Command.new
            format.html { render :action => "new" }
          else
            flash[:notice] = "Imported #{valid_commands.size} of #{(valid_commands + invalid_commands).size} commands from your uploaded bookmarks file."
            format.html { redirect_to current_user.home_path }
          end
      end
            
    else
      
      # User filled out form to create single command
      
      @command = current_user.commands.new(params[:command])
      
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
    if @command.user != current_user
      redirect_failed_permission
      return
    end

    respond_to do |format|
      if @command.update_attributes(params[:command])
        @command.update_tags(params[:tags])
        flash[:notice] = "Command updated: <b><a href='#{@command.show_path}'>#{@command.name}</a></b>"
        format.html { redirect_back_or_default current_user.home_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @command.errors.to_xml }
      end
    end
  end

  def destroy
    @command.destroy

    respond_to do |format|
      flash[:notice] = "Command deleted: <b>#{@command.name}</b>"      
      format.html { redirect_to current_user.home_path }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def parse_tag_input
    keyword_string, tags = params[:v].split(/\s+/, 2)
    keywords = keyword_string.split(',')
    return keywords, tags
  end
  
  def render_tag_action(tag_string, keywords, successful_commands)
    if tag_string.blank?
      flash[:warning] = "No tags specified. Please try again."
      redirect_to current_user.commands_path
    elsif successful_commands.empty?
      flash[:warning] = "Failed to find commands: #{keywords.to_sentence}"
      redirect_to current_user.commands_path
    else
      flash[:notice] = "Updated tags for commands: #{successful_commands.map(&:keyword).to_sentence}."
      redirect_to successful_commands[0].show_path
    end
  end
  
  def index_pagination_params
    {:order => "commands.queries_count_all DESC", :page => params[:page], :include => [:tags]}
  end
  
  def load_command_by_user_and_keyword
    action_include_hash = {'edit'=>[:user], 'destroy'=>[:queries]}
    @command = @user.commands.find_by_keyword(params[:command], :include=>action_include_hash[self.action_name] || [])
    command_is_nil? ? false : true
  end
  
  def redirect_failed_permission
    flash[:warning] = "You are not allowed to modify this command!" 
    redirect_to current_user.home_path
  end
  
  def permission_required_for_user
    if ! owner?
      redirect_failed_permission
      return false
    end
    true
  end
  
  def command_is_nil?
    if @command.nil?
      flash[:warning] = "User #{@user.login} has no command with keyword '#{params[:command]}'"
      redirect_to @user.home_path
      return true
    end
    false
  end

end
