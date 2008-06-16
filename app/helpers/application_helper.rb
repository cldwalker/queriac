module ApplicationHelper
  include PathHelper, SharedHelper, TableHelper

  def render_page_title
    if breadcrumbs.empty?
      "Queriac. All our quicksearches are belong to us."
    else
      breadcrumbs.map {|e| e.is_a?(Array) ? e[0].tr(" ", '_') : e.tr(' ', '_') }.join("/")
    end
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
      crumbs << [@command.keyword, command_path(@command)]
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
        crumbs << 'commands'
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
      crumbs << params[:action]
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
    items << link_to_unless_current("help", help_path)
    items << link_to_unless_current("tutorial", tutorial_path)
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
  
  def flash_div 
    flash.keys.collect { |key| content_tag( :div, flash[key], :class => "flash-msg #{key}" ) if flash[key] }.join
  end
  
  def tag_cloud(otags)
    tags = {}
    
    # count number of tags
    otags.each { |t| tags[t.name] = tags.has_key?(t.name) ? tags[t.name]+1 : 1 }

    output = tags.sort.collect{|t|
      name = t[0]
      num = t[1]
      opacity = (50 + [num, 10].min.to_f/2*10).to_f/100
      font_size = (80 + [num, 20].min.to_f*5).to_f
      link_to("#{name}", tagged_user_commands_path(@user, name), :title => "#{name} (#{num})", :style => "opacity:#{opacity};font-size:#{font_size}%;") 
    }.join(" ")
    content_tag(:p, output, :class => "tags")
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
    label = query.query_string.empty? ? "(Command run with no parameters)" : query.query_string.ellipsize
    klass = query.query_string.empty? ? "faded" : ""
    link_to(label, query.user_command.url_for(query.query_string), :class => klass, :title=>"Date: #{query.created_at.to_s(:long)}")
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
      #FIXME: second half of OR statement w/ '/' only there until q command is fixed to not have '/' at the end
      @current_page_uri == url_string || @current_page_uri == url_string + "/"
    end
  end
  
  def pagination_description(will_paginate_collection)
    possible_last_item = will_paginate_collection.per_page * will_paginate_collection.current_page
    last_item = possible_last_item < will_paginate_collection.total_entries ? possible_last_item : will_paginate_collection.total_entries
    %[#{will_paginate_collection.offset + 1}-#{last_item} of #{will_paginate_collection.total_entries}]
  end
end
