class UserCommandsController < ApplicationController
  include CommandsControllerHelper
  before_filter :login_required, :except => [:index, :show, :command_user_commands, :help]
  before_filter :load_valid_user_if_specified, :only=>[:index, :show, :help]
  before_filter :set_user_command, :only=>[:show, :edit, :update, :destroy, :update_url, :help]
  before_filter :set_command, :only=>[:command_user_commands]
  before_filter :permission_required_if_private, :only=>[:show, :help]
  before_filter :permission_required, :only=>[:edit, :update, :destroy, :update_url]
  before_filter :store_location, :only=>[:index, :show, :command_user_commands]
  before_filter :allow_breadcrumbs, :only=>[:search, :index, :command_user_commands, :show, :edit, :help]
  before_filter :set_disabled_fields, :only=>[:subscribe, :edit]
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
  
  def old_index
    redirect_to tagged_user_commands_path(params[:login], *params[:tag]), :status=>301
  end
  
  def command_user_commands
    @user_commands = @command.user_commands.paginate(index_pagination_params.merge(:order=>sort_param_value))
    render :action=>'index'
  end
  
  def show
    @related_user_commands, @queries = user_command_owner? ? @user_command.show_page(can_view_queries?) : 
      @user_command.cached(:show_page, :with=>can_view_queries?, :ttl=>15.minutes)
  end
  
  def help
  end
  
  def new  
    @user_command = UserCommand.new
    #Allow user to pre-populate form
    @user_command.attributes = params.slice(:name, :keyword, :url, :description)
  end
  
  def copy
    if (@source_object = setup_source_object)
      setup_new_from_source(@source_object)
      flash.now[:notice] = "If you don't intend to change the url, options or public state of this command, you should use subscribe instead."
    end
  end
  
  def subscribe
    if (@source_object = setup_source_object)
      source_command = @source_object.is_a?(UserCommand) ? @source_object.command : @source_object
      @command_id = source_command.id
      if (existing_user_command = source_command.user_commands.detect {|e| e.user_id == current_user.id}) #source_command.owned_by?(current_user)
        flash[:notice] = "No need to #{@source_verb} this command. You already have " + 
          render_to_string(:inline=>%[<%= basic_user_command_link(existing_user_command) %>], :locals=>{:existing_user_command=>existing_user_command})
        redirect_back_or_default public_user_command_path(existing_user_command)
        return
      end
      setup_new_from_source(@source_object)
    end
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
              <%= link_to basic_user_command_link(existing_user_command) %>", :locals=>{:existing_user_command=>existing_user_command}
          end
          set_disabled_fields #for subscribe
          format.html { render :action => "new" }
          #format.xml  { render :xml => @command.errors.to_xml }
        end
      end
      
  end

  def update
    respond_to do |format|
      if @user_command.update_all_attributes(params[:user_command].merge(:url_options=>get_url_options), current_user, :command_fields=>params[:command_fields]|| [])
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
      message =  "Url and options updated."
      message += "But since you were editing, also reload your page." if (request.env["HTTP_REFERER"] == edit_user_command_url(@user_command))
      page.replace 'url_status', message
    end
  end

  def destroy
    @user_command.destroy
    flash[:notice] = "User command deleted: <b>#{@user_command.name}</b>"      
    redirect_back_or_default user_home_path(current_user)
  end
  
  def tag_add_remove
    tag_add_remover {|e| current_user.user_commands.find_by_keyword(e)}
  end
  
  def tag_set
    tag_setter {|e| current_user.user_commands.find_by_keyword(e)}
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
    Option.detect_and_add_params_to_options(options, params[:user_command_url])
    
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
  
  def fetch_and_sync_url_options
    @user_command = UserCommand.new
    scrape_options = {:text=>params[:text], :form_number=>params[:form_number], :is_admin=>admin?}
    parser_response = FormParser.scrape_form(params[:url], scrape_options)
    if parser_response.success
      action_url, options, hpricot_form = parser_response.action_url, parser_response.url_options, parser_response.form
      http_post = hpricot_form['method'].to_s.downcase == 'post'
      command_url, options, message = FormParser.create_command_url_and_options_from_scrape(action_url, options, {:is_admin=>admin?})
      render :update do |page|
        page << "$(url_input_id).value = '#{command_url}'"
        page.replace_html :user_command_options, :partial=>'options', :locals=>{:options=>options}
        page << %[Effect.BlindDown('url_options'); Element.show('url_optionsCollapse'); Element.hide('url_optionsExpand');]
        page << %[$('user_command_http_post').checked = true] if http_post
        page.xhr_flash(:notice, message, 10) unless message.blank?
      end
    else
      render :update do |page|
        page.xhr_flash :warning, parser_response.error_message
      end
    end
  end
  
  def fetch_form
    if request.post?
      scrape_options = {:text=>params[:text], :form_number=>params[:form_number], :is_admin=>admin?}
      parser_response = FormParser.scrape_form(params[:url], scrape_options)
      if parser_response.success
        @action_url, @options, @form = parser_response.action_url, parser_response.url_options, parser_response.form
        @action_url ||= @form['action'] rescue nil
        flash[:notice] = 'Fetch succeeded.'
      else
        @options = nil
        flash[:warning] = parser_response.error_message
      end
    end
  end
  
  def valid_sort_columns; %w{name queries_count created_at keyword}; end
  
  protected
  def get_url_options
    if (url_options = params[:user_command].delete(:url_options))
      #only for update action- automagically merge new options from url
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
  
  def permission_required_if_private
    if @user_command.private? && ! user_command_owner_or_admin?
      flash[:warning] = "Sorry, the command '#{@user_command.name}' is private."
      redirect_to logged_in? ? user_home_path(current_user) : home_path
      return false
    end
    true
  end
  
  def set_disabled_fields
    options = {}
    options[:subscribe] = true if subscribe_action? || params[:is_subscribe]
    @disabled_fields = get_disabled_fields(current_user, options)
  end
  
  def get_disabled_fields(current_user, options={})
    if options[:subscribe]
      disabled_fields = [:url, :public]
    elsif ! @user_command.new_record?
      disabled_fields = @user_command.get_disabled_update_fields(current_user)
  	else
  	  disabled_fields = []
    end
  	disabled_fields
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

  def setup_new_from_source(source_object)
    @user_command = UserCommand.new
    @user_command.attributes = source_object.attributes.slice(*%w{name keyword url description})
    @user_command.url_options = Option.sanitize_copied_options(source_object.url_options)
    render :action=>'new'
  end
  
  def setup_source_object
    source_object = params[:is_command] ? Command.find(params[:id]) : UserCommand.find(params[:id])
    @source_verb = subscribe_action? ? "subscribe to" : 'copy'
    if source_object.private?
      flash[:warning] = "You cannot #{@source_verb} a private command." 
      redirect_back_or_default home_path
      return nil
    end
    source_object
  end
end