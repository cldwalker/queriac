module ApplicationHelper
  include PathHelper, SharedHelper, TableHelper

  def render_page_title
    if breadcrumbs.empty?
      default_title
    else
      @title = breadcrumbs.map {|e| e.is_a?(Array) ? e[0].tr(" ", '_') : e.tr(' ', '_') }.join("/")
    end
    @title
  end
  
  def render_nav
    if breadcrumbs.empty?
      link_to('queriac', home_path)
    else
      breadcrumbs.map {|e| e.is_a?(Array) ? link_to(*e) : e }.join(" &raquo; ")
    end
  end
  
  def breadcrumbs
    @breadcrumbs ||= get_crumbs
  end
  
  #can use boolean @breadcrumbs_allowed to include/exclude actions from breadcrumbs
  def get_crumbs
    crumbs = [['queriac', home_path]]
    return [] unless @breadcrumbs_allowed
    #set_command filter
    if @command
      crumbs << ["commands", commands_path]
      crumbs << [@command.to_param.to_s, command_path(@command)]
      if params[:controller] == 'queries'
        crumbs << 'queries'
      elsif params[:controller] == 'user_commands'
        crumbs << 'user commands'
      end
    #most are set_user_command filter
    elsif @user_command
      crumbs << [@user_command.user.login, user_home_path(@user_command.user)]
      crumbs << [@user_command.keyword, public_user_command_path(@user_command)]      
      if params[:controller] == 'queries'
        crumbs << 'queries'
      end
    elsif @user
      crumbs << [@user.login, user_home_path(@user)]
      if params[:controller] == 'queries'
        crumbs << 'queries'
        add_tags_to_crumbs(crumbs)
      elsif params[:controller] == 'user_commands'
        crumbs << 'user commands'
        add_tags_to_crumbs(crumbs)
        end
    #index-ish user_controller actions
    elsif @user_commands && params[:controller] == 'user_commands'
      crumbs << ['user commands', user_commands_path]
      add_tags_to_crumbs(crumbs)
    elsif @commands && params[:controller] == 'commands'
      crumbs << ['commands', commands_path]
    elsif @users && params[:controller] = 'users'
      crumbs << ['users', users_path]
    elsif @queries && params[:controller] == 'queries'
      crumbs << ['queries', queries_path]
      add_tags_to_crumbs(crumbs)
    elsif params[:controller] == 'static'
      crumbs << params[:static_page]
    end
    crumbs
  rescue
    logger.info "BREADCRUMB FAILED: "
    logger.info $!
    logger.info "breadcrumb_parent: #{@breadcrumb_parent}"
    logger.info "crumbs: #{crumbs.inspect}"
    ['queriac', home_path]
  end
  
  def add_tags_to_crumbs(crumbs)
    if ! @tags.blank?
      crumbs << "tag"
      crumbs << @tags.join("+")
    end
  end
  
  def render_mininav
    items = []
    items << "logged in as " + link_to(current_user.login, user_home_path(current_user), :class => "underlined") if logged_in?
    items << link_to_unless_current("settings", settings_path) if logged_in?
    items << link_to_unless_current("help", static_page_path('help'))
    items << link_to_unless_current("tutorial", static_page_path('tutorial'))
    items << link_to("logout", session_path(session), :confirm => "Are you sure you want to log out?", :method => :delete) if logged_in?
    items << link_to("sign up", new_user_path) unless logged_in?
    items << link_to("log in", new_session_path) unless logged_in?
    output = ""
    items.each_with_index do |item, index|
      klass = (index == items.size-1) ? 'class="last"' : ''
      output << "<li #{klass}>#{item}</li>"
    end
    content_tag(:ul, output)
  end
  
  def nofollow_link_to(name, options = {}, html_options = nil, *parameters_for_method_reference)
    link_to(name, options, (html_options || {}).merge(:rel=>'nofollow'), *parameters_for_method_reference)
  end
  
  def flash_div 
    flash.keys.collect { |key| content_tag( :div, flash[key], :class => "flash-msg #{key}" ) if flash[key] }.join
  end
  
  def xhr_flash(type=:notice, message=flash.now[:notice], delay_time=5)
    page.insert_html :top, :content, <<-HTML
      <div id='ajax_notice_div' class='flash-msg #{(type == :notice) ? "notice" : "warning"}'>
        #{message}
      </div>
    HTML
    if delay_time > 0
      page.delay(delay_time) { page.visual_effect :fade, 'ajax_notice_div' }
    end
  end
  
  def tag_cloud(otags)
    output = count_tags_by_name(otags).sort.collect{ |name, num|
      opacity = (50 + [num, 10].min.to_f/2*10).to_f/100
      font_size = (80 + [num, 20].min.to_f*5).to_f
      link_to("#{name}", tagged_user_commands_path(@user, name), :title => "#{name} (#{num})", :style => "opacity:#{opacity};font-size:#{font_size}%;") 
    }.join(" ")
    content_tag(:p, output, :class => "tags")
  end
  
  def count_tags_by_name(otags)
    unless @tags_by_name
      @tags_by_name = {}
      otags.each { |t| @tags_by_name[t.name] = @tags_by_name.has_key?(t.name) ? @tags_by_name[t.name]+1 : 1 }
    end
    @tags_by_name
  end
  
  def tag_list(otags)
    #group tag names by tag count
    tags_by_number = {}
    count_tags_by_name(otags).each {|k,v| tags_by_number[v] ||= []; tags_by_number[v] << k }
    tags_by_number = tags_by_number.sort {|a,b| b[0] <=> a[0]}
    
    content_tag(:ul, :class=>'normal') do
      tags_by_number.map do |tag_count, tag_names|
        tags = tag_names.map {|e| link_to(e, tagged_user_commands_path(@user, e))}.join(", ")
        content_tag(:li, "#{tag_count}: #{tags}", :class=>'normal')
      end.join("\n")
    end
  end
  
  def tag_cloud_or_list(tags, options={})
    options.reverse_merge!(:link_options => {})
    list_link = link_to_function('List', "this.up('div').next().show(); this.up('div').hide()", options[:link_options])
    cloud_text = content_tag(:h3, "Cloud | #{list_link}", :style=>"margin-bottom: 10px") + tag_cloud(tags)
    cloud_link = link_to_function('Cloud', "this.up('div').previous().show(); this.up('div').hide()", options[:link_options])
    list_text =  content_tag(:h3, "#{cloud_link} | List", :style=>"margin-bottom: 10px") + tag_list(tags)
    all_text = content_tag(:div, cloud_text) + content_tag(:div, list_text, :style => 'display:none;')
  end
  
  # Dynamic expand/collapse
  def expander_for(field_id, options={})
    label = options[:label] || "Expand"
    autohide = options[:autohide] || false
    o = "<a id='#{field_id}Expand' href='#' onclick=\"Effect.BlindDown('#{field_id}'); Element.show('#{field_id}Collapse'); Element.hide('#{field_id}Expand'); return false;\">#{label}</a>\n"    
    o << javascript_tag("Element.hide('#{field_id}Expand');") if autohide
    return o
  end
  
  def collapser_for(field_id, options={})
    label = options[:label] || "Collapse"
    autohide = options[:autohide] || false
    o = "<a id='#{field_id}Collapse' href='#' onclick=\"Effect.BlindUp('#{field_id}'); Element.hide('#{field_id}Collapse'); Element.show('#{field_id}Expand'); return false;\">#{label}</a>\n"
    o << javascript_tag("Element.hide('#{field_id}Collapse');") if autohide
    return o
  end
  
  def hide field_id
    javascript_tag("Element.hide('#{field_id}');")
  end
  
  def link_to_query(query)
    label = query.query_string.empty? ? "(Command run with no parameters)" : h(query.query_string.ellipsize)
    klass = query.query_string.empty? ? "faded" : ""
    nofollow_link_to(label, h(query.user_command.url_for(query.query_string)), :class => klass, :title=>"Date: #{query.created_at.to_s(:long)}")
  end
  
  def query_user(query)
    query.user ? link_to(query.user.login, user_home_path(query.user)) : '--' # + query.user_command.user.login
  end
  
  # Use words if within the last week
  # otherwise use date (show year if not this year)
  def time_ago_in_words_or_date(date)
    if (Time.now-date)/60/60/24 < 7
      time_ago_in_words(date) + " ago"
    elsif date.year == Time.now.year
      date.to_s(:short)
    else
      date.to_s(:medium)
    end
  end
    
  def whose_commands(command)
    command.user == current_user ? "Your" : "#{@user.login}'s public"
  end

  def render_favicon_for_command(command)
    image_tag(command.favicon_url, :alt => "", :width => "16", :height => "16")
  end
  
  #more forgiving than current_page? since it doesn't expect params to match
  def current_page_matches?(options)
    url_string = CGI.escapeHTML(url_for(options))
    request = @controller.request
    if url_string =~ /^\w+:\/\//
      url_string == "#{request.protocol}#{request.host_with_port}#{request.request_uri}"
    else
      #request.request_uri.include?(url_string)
      @current_page_uri ||= request.request_uri.sub(/\?.*$/,'')
      @current_page_uri == url_string
    end
  end
  
  def pagination_description(will_paginate_collection)
    first_item = will_paginate_collection.size == 0 ? 0 : "#{will_paginate_collection.offset + 1}" 
    possible_last_item = will_paginate_collection.per_page * will_paginate_collection.current_page
    last_item = possible_last_item < will_paginate_collection.total_entries ? possible_last_item : will_paginate_collection.total_entries
    %[#{first_item}-#{last_item} of #{will_paginate_collection.total_entries}]
  end
  
  def sort_description
    direction, preposition, column = params[:sort].scan(/^([a-z]+)_([a-z]+)_(.*)$/).flatten
    return '' unless @controller.valid_sort_columns.include?(column)
    #chopping off first word in underscored column ie created_at -> created and queries_sort-> queries
    column = column[/[a-z]+/]
    "sorted #{direction} #{preposition} #{column}"
  end
  
  def default_title
    @title ||= "Queriac. All our quicksearches are belong to us."
  end
  
  def set_rss_header_defaults
    default_title
  end
  
  def ajax_spinner(id='processing')
    %[<div id="#{id}_spinner" class="spinner" style="display:none"> &nbsp;</div>]
  end
  
  def truncate_with_more(text, length=nil, options={})
    tag_type = options[:tag_type] || 'div'
    length ||= 300
    return text if text.length <= length
    options.reverse_merge!(:more => "more &gt;", :less => "&lt; less", :link_options => {}, :truncate_string => "...")
    if text
      morelink = link_to_function(options[:more], "$(this).up('#{tag_type}').next().show(); $(this).up('#{tag_type}').hide()", options[:link_options])
      starter = truncate(text, length, options[:truncate_string]) +  " #{morelink}"
      lesslink = link_to_function(options[:less], "$(this).up('#{tag_type}').previous().show(); $(this).up('#{tag_type}').hide()", options[:link_options])
      all_text = content_tag(tag_type, starter)+content_tag(tag_type, "#{text} #{lesslink}", :style => 'display:none;')
    end
  end
  
  #command or user command methods
  def command_description(command)
    simple_format command.description.blank? ? 'No description yet.' : command.description
  end
  
  def option_metadata(option, options={})
    metadata = []
    metadata << "param: #{h option.param}" unless option.param.blank?
    metadata << "description: #{h option.description}" unless option.description.blank?
		metadata << "allowed values: #{truncate_with_more h(option.sorted_values), 70, :tag_type=>'span'}" unless option.values.blank?
		if option.option_type == 'boolean'
  		metadata << "true value: #{h option.true_value}" unless option.true_value.blank?
  		metadata << "false value: #{h option.false_value}" unless option.false_value.blank?
  	else
  		metadata << "default: #{h option.default}" unless option.default.blank?
  	end
		metadata << "alias: #{h option.alias}" unless option.alias.blank?
		metadata << "value prefix: #{h option.value_prefix}" unless option.value_prefix.blank?
	  if options[:show_all]
		  metadata << "value aliases: #{h option.value_aliases}" unless option.value_aliases.blank?
		end
		
		return '' if metadata.empty?
		content_tag(:ul) do
		  metadata.map {|e| content_tag(:li, e, :style=>'margin: 0px 0px 2px 0px')}.join("\n")
		end
  end
  
end
