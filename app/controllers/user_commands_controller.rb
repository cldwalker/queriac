class UserCommandsController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :command_user_commands]
  before_filter :load_valid_user_if_specified, :only=>[:index, :show]
  before_filter :set_user_command, :only=>[:show, :edit, :update, :destroy, :update_url]
  before_filter :set_command, :only=>[:command_user_commands]
  before_filter :permission_required, :only=>[:edit, :update, :destroy, :update_url]
  before_filter :store_location, :only=>[:index, :show, :command_user_commands]
  before_filter :allow_breadcrumbs, :only=>[:search, :index, :command_user_commands, :show, :edit]
  before_filter :set_disabled_fields, :only=>[:copy, :edit]
  before_filter :load_tags_if_specified, :only=>:index
  before_filter :add_rss_feed, :only=>[:index, :command_user_commands]
  
  # Possiblities..
  # /user_commands                   => public commands
  # /user_commands/tag/google        => public commands for a tag or tags
  # /zeke/commands/             => all || public commands for a specific user
  # /zeke/commands/tag/google   => all || public commands for a specific user for a tag or tags
  def index
    publicity = (current_user? || admin?) ? "any" : "public"

    if @tags
      clear_rss_feed #disabled feed because tag paths with a dot are blocked by current feed which also uses a dot
      if @user
        @user_commands = @user.user_commands.send(publicity).find_tagged_with(@tags.join(", "), :match_all => true, :order=>'user_commands.queries_count DESC').paginate(index_pagination_params)
      else
        @user_commands = UserCommand.send("public").find_tagged_with(@tags.join(", "), :match_all => true, :order=>'user_commands.queries_count DESC').paginate(index_pagination_params)
      end
    else
      if @user
        @user_commands = @user.user_commands.send(publicity).paginate(index_pagination_params.merge(:order=>sort_param_value))
      else
        @user_commands = UserCommand.send("public").paginate(index_pagination_params.merge(:order=>sort_param_value('user_commands.created_at DESC')))
      end
    end

    if @user_commands.empty? && @tags.nil?
      flash[:warning] = "Sorry, no user commands matched your request."
      redirect_to home_path
      return
    end

    respond_to do |format|
      format.html
      format.rss
      format.atom
      format.xml
    end
  end
  
  def command_user_commands
    @user_commands = @command.user_commands.paginate(index_pagination_params.merge(:order=>sort_param_value))
    render :action=>'index'
  end
  
  def show
    if @user_command.private? && ! user_command_owner_or_admin?
      flash[:warning] = "Sorry, the command '#{@user_command.name}' is private."
      redirect_to user_home_path(current_user)
      return
    end
    @related_user_commands = @user_command.command.user_commands.find(:all, :limit=>5, :order=>'user_commands.queries_count DESC', :include=>:user)
    if can_view_queries?
      @queries =  @user_command.queries.find(:all, :limit=>30, :order=>'queries.created_at DESC', :include=>:user_command)
    else
      @queries = []
    end

    respond_to do |format|
      format.html
      #format.xml  { render :xml => @command.to_xml }
    end
  end
  
  def new  
    @user_command = UserCommand.new
    #Allow user to pre-populate form
    @user_command.attributes = params.slice(:name, :keyword, :url, :description)
  end
  
  def copy
    if params[:is_command]
      @base_command = Command.find(params[:id])
      if @base_command.nil?
        flash[:warning] = "Unable to copy command"
        redirect_back_or_default command_path(@base_command)
        return
      end
      @command_id = @base_command.id
    else
      @original_command = UserCommand.find(params[:id])
      @command_id = @original_command.command_id
    end
    if (@original_command || @base_command).private?
      flash[:warning] = "You cannot copy a private command." 
      redirect_back_or_default home_path
      return
    else
      if @original_command && (existing_user_command = @original_command.command.user_commands.detect {|e| e.user_id == current_user.id}) #@original_command.owned_by?(current_user)
        flash[:notice] = "No need to copy this command. You already have " + 
          render_to_string(:inline=>%[<%= link_to('it', public_user_command_path(existing_user_command)) %>], :locals=>{:existing_user_command=>existing_user_command})
        redirect_back_or_default public_user_command_path(existing_user_command)
        return
      elsif @base_command && (existing_user_command = @base_command.user_commands.detect {|e| e.user_id == current_user.id})
        flash[:notice] = "No need to copy this command. You already have "  + 
          render_to_string(:inline=>%[<%= link_to('it', public_user_command_path(existing_user_command)) %>], :locals=>{:existing_user_command=>existing_user_command})
        redirect_back_or_default public_user_command_path(existing_user_command)
        return
      end
    end
    
    @user_command = UserCommand.new
    @user_command.attributes = (@original_command || @base_command).attributes.slice(*%w{name keyword url description url_options})
    render :action=>'new'
  end
  
  def edit
  end
  
  def import
    
    if request.post?
      
      if params['bookmarks_file'].blank?
        flash[:warning] = 'Not a valid bookmark file, try again.'
      else        
        new_file = "#{RAILS_ROOT}/public/bookmark_files/#{Time.now.to_s(:ymdhms)}.html"
        File.open(new_file, "wb") { |f| f.write(params['bookmarks_file'].read) }
        valid_commands, invalid_commands = Command.create_commands_for_user_from_bookmark_file(current_user, new_file)
        @user_commands = valid_commands
        flash[:notice] = "Imported #{valid_commands.size} of #{(valid_commands + invalid_commands).size} commands from your uploaded bookmarks file."
        
      end
    end     
  end
  
  def create
      if params[:commit] && params[:commit].include?('Cancel')
        redirect_back_or_default home_path
        return
      end
      
      @user_command = current_user.user_commands.new(params[:user_command].merge(:url_options=>get_url_options))
      
      respond_to do |format|      
        if @user_command.save
          @user_command.update_tags(params[:tags])
          flash[:notice] = "New command created: <b><a href='#{public_user_command_path(@user_command)}'>#{@user_command.name}</a></b>"
          format.html { redirect_to user_home_path(current_user) }
          #format.xml  { head :created, :location => command_url(@user_command) }
        else
          if @user_command.errors[:command_id] && 
            (existing_user_command = current_user.user_commands.find(:first, :conditions=>{:command_id=>@user_command.command_id}))
            flash.now[:warning] = render_to_string :inline=>"The url entered indicates that you already have this command: 
              <%= link_to existing_user_command.name, public_user_command_path(existing_user_command) %>", :locals=>{:existing_user_command=>existing_user_command}
          end
          set_disabled_fields #for copy
          format.html { render :action => "new" }
          #format.xml  { render :xml => @command.errors.to_xml }
        end
      end
      
  end

  def sync_url_options
    if params[:user_command]
      @user_command = UserCommand.find(params[:user_command])
      url_options = @user_command.merge_url_options_with_options_in_url(params[:user_command_url])
      options = @user_command.ordered_url_options(url_options, params[:user_command_url])
    else
      #@user_command needed for options template
      @user_command = UserCommand.new
      options = UserCommand.new.options_from_url(params[:user_command_url]).map {|e| Option.new(:name=>e)}
    end
    render :update do |page|
      page.replace_html :user_command_options, :partial=>'options', :locals=>{:options=>options}
  	end
	end
	
	def change_option_type_fields
    render :update do |page|
      page.replace_html "option_type_specific_fields_#{params[:index]}", :partial=>'option_type_specific_fields'
  	end
	end
  
  def update_default_picker
    @values = Option.new.values_list(params[:values]) + [nil]
    render :update do |page|
      page.replace_html "user_command_url_options_#{params[:index]}_default", :inline=>%[
        <%= options_for_select @values %>
      ]
  	end
  end
  
  def update
    respond_to do |format|
      if @user_command.update_all_attributes(params[:user_command].merge(:url_options=>get_url_options), current_user)
        @user_command.update_tags(params[:tags])
        flash[:notice] = "Command updated"
        format.html { redirect_back_or_default public_user_command_path(@user_command) }
        #format.xml  { head :ok }
      else
        set_disabled_fields
        format.html { render :action => "edit" }
        #format.xml  { render :xml => @user_command.errors.to_xml }
      end
    end
  end
  
  def update_url
    @user_command.update_url_and_options
    render :update do |page|
      page.replace 'url_status', "Url and options updated"
    end
  end

  def destroy
    @user_command.destroy
    flash[:notice] = "User command deleted: <b>#{@user_command.name}</b>"      
    redirect_back_or_default user_home_path(current_user)
  end
  
  def tag_add_remove
    keywords, tag_string = parse_tag_input
    
    successful_commands = []
    unless tag_string.blank?
      #TODO: should move \w+ to a validation regex constant
      remove_list, add_list = tag_string.scan(/-?\w+/).partition {|e| e[0,1] == '-' }
      remove_list.map! {|e| e[1..-1]}
      keywords.each do |n| 
        if (cmd = current_user.user_commands.find_by_keyword(n))
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
        if (cmd = current_user.user_commands.find_by_keyword(n))
          cmd.update_tags(tag_string)
          edited_commands << cmd
        end
      end
    end
    render_tag_action(tag_string, keywords, edited_commands)
  end
  
  def search
    if params[:q].blank?
      flash[:warning] = "Your search is empty. Try again."
      @user_commands = [].paginate
    else
      @user_commands = current_user.user_commands.search(params[:q]).paginate(index_pagination_params.merge(:order=>sort_param_value, :include=>[:tags, :command]))
    end
    render :action => 'index'
  end

  def copy_yubnub_command
    #keyword regex is strict for now, should find out what is an acceptable yubnub command
    if params[:keyword] && (keyword = params[:keyword].scan(/^\w+/).first)
      begin
        if (doc = Hpricot(open("http://yubnub.org/kernel/man?args=#{keyword}")))
          if (url = (doc/"span.muted")[0].inner_html)
            if url[/\{.*\}/]
              flash[:notice] = "Yubnub syntax was detected in the command url. Since we don't parse the same way yubnub does,
                the url will point to yubnub's parser."
              url = %[http://yubnub.org/parser/parse?command=#{keyword} (q)]
            end
            new_params = {:action=>'new', :keyword=>keyword, :url=>url}
            description = (doc/"pre").first.inner_html rescue nil
            new_params.merge!(:description=>description) if description
            redirect_to new_params
            return
          end
        end
      rescue
        flash[:warning] = "Failed to parse yubnub keyword '#{params[:keyword]}'"
        redirect_back_or_default user_home_path(current_user)
        return
      end
      flash[:warning] = "Failed to parse yubnub keyword '#{params[:keyword]}'"
    else
      flash[:warning] = "The keyword '#{params[:keyword]}' is not a valid keyword. Please try again."      
    end
    redirect_back_or_default user_home_path(current_user)
  end

  #js example at http://ostermiller.org/bookmarklets/form.html- Extract Forms
  def scrape_form
    unless params[:url].blank? && params[:text].blank?
      if !params[:url].blank?
        text = open(params[:url])
      elsif !params[:text].blank?
        text = params[:text]
      end
      if (@form = (Hpricot(text)/"form")[0])
        form_text = @form.to_html 
        @options = Option.scrape_options_from_form(form_text)
      else
        flash[:notice] = 'No form found.'
      end
    end
  rescue Errno::ENOENT
    flash[:warning] = "Invalid url. Perhaps you misspelled it?"
  rescue
    flash[:warning] = "Scrape failed. Try again later."
    @options = nil
    logger.error "Scrape failed with error: #{$!}\n:url #{params[:url]} and/or text:\n#{params[:text]}"
  end
  
  def valid_sort_columns; %w{name queries_count created_at keyword}; end
  
  protected
  def get_url_options
    if (url_options = params[:user_command].delete(:url_options))
      #only for update action
      if @user_command
        new_url_options = Option.sanitize_input(url_options.values)
        if @user_command.options_from_url(params[:user_command][:url]).sort != @user_command.options_from_url_options(new_url_options).sort
          return @user_command.merge_url_options_with_options_in_url(params[:user_command][:url])
        end
      end
      url_options.values
    else
      #merge url options based on given url
      (@user_command || UserCommand.new).merge_url_options_with_options_in_url(params[:user_command][:url])
    end
  end
  
  def sort_param_value(default_sort = 'user_commands.queries_count DESC')
    general_sort_param_value('user_commands', valid_sort_columns, default_sort)
  end
  
  #PERF: pagination at 15 for performance
  def index_pagination_params
    #PERF: avoiding :include=>:tags b/c it's slower
    # {:page => params[:page], :per_page=>15, :include => [:tags, :command, :user], :order=>"user_commands.queries_count DESC"}
    {:page => params[:page], :per_page=>15, :include => [:command, :user], :order=>"user_commands.queries_count DESC"}
  end

  #only command owner can access their usercommands for most actions due to current routes
  #hence no admin permission
  def permission_required
    if @user_command.owned_by?(current_user)
      return true
    else
      flash[:warning] = "You don't have permission to access this command."
      redirect_back_or_default user_home_path(current_user)
      return false
    end
  end
  
  def set_user_command
    #for public_user_command_path
    if @user
      @user_command = @user.user_commands.find_by_keyword(params[:id])
    else
      return false unless login_required #only needed for show
      @user_command = current_user.user_commands.find_by_keyword(params[:id])
    end
    return false if user_command_is_nil?(params[:id])
    true
  end
  
  def set_disabled_fields
    options = {}
    options[:copy] = true if self.action_name == 'copy' || params[:is_copy]
    @disabled_fields = get_disabled_fields(current_user, options)
  end
  
  def get_disabled_fields(current_user, options={})
    if options[:copy]
      disabled_fields = [:url, :public]
    elsif ! @user_command.new_record?
      disabled_fields = @user_command.get_disabled_update_fields(current_user)
  	else
  	  disabled_fields = []
    end
  	disabled_fields
  end
  
  def parse_tag_input
    return nil, nil unless params[:v]
    keyword_string, tags = params[:v].split(/\s+/, 2)
    keywords = keyword_string.split(',')
    return keywords, tags
  end
  
  def render_tag_action(tag_string, keywords, successful_commands)
    if tag_string.blank?
      flash[:warning] = "No tags specified. Please try again."
      redirect_to specific_user_commands_path(current_user)
    elsif successful_commands.empty?
      flash[:warning] = "Failed to find commands: #{keywords.to_sentence}"
      redirect_to specific_user_commands_path(current_user)
    else
      flash[:notice] = "Updated tags for commands: #{successful_commands.map(&:keyword).to_sentence}."
      redirect_back_or_default public_user_command_path(successful_commands[0])
    end
  end
  
end

__END__
#maybe implement later
def search_all
  if params[:q].blank?
    flash[:warning] = "Your search is empty. Try again."
    @commands = [].paginate
  else
    #:select + :group ensure unique urls for commands
    all_commands = Command.find(:all, :conditions=>["keyword REGEXP ? OR url REGEXP ?", params[:q], params[:q]],
      :select=>'*, count(url)', :group=>"url HAVING count(url)>=1", :order=>'queries_count_all DESC' )
    @commands = all_commands.paginate(index_pagination_params)
  end
  render :action => 'index'
end

