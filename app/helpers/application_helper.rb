module ApplicationHelper
  include PathHelper, SharedHelper

  #TODO: clean up + perhaps combine render_page_title + render_nav
  def render_page_title
    if @user || @command || @tags || params[:controller] == "users"
      crumbs = ["queriac"]
      crumbs << "users" if current_page_matches?(users_path)
      crumbs << @user.login if @user
      crumbs << "commands" unless @commands.nil?
      if ! @tags.blank? && ! current_page_matches?(user_home_path(@user))
        crumbs << "tag"
        crumbs << @tags.join("+")
      end
      crumbs << @command.keyword unless @command.blank? || @command.new_record?
      crumbs << "queries" if params[:controller] == "queries"
      return crumbs.join("/")
    else 
      return "Queriac. All our quicksearches are belong to us."
    end
  end
  
  #TODO: enable breadcrumbs once new routes are stable
  def render_nav
    return
    crumbs = [link_to("queriac", home_path)]
    crumbs << link_to("users", users_path) if current_page_matches?(users_path)
    crumbs << link_to(@user.login, user_home_path(@user)) if @user
    crumbs << link_to("commands", specific_user_commands_path(@user)) if @user && !@commands.nil? && ! current_page_matches?(user_home_path(@user))
    crumbs << link_to("queries", user_queries_path(@user)) if params[:controller] == "queries" && @user
    crumbs << link_to("queries", queries_path) if current_page_matches?(queries_path)
    if ! @tags.blank? && ! current_page_matches?(user_home_path(@user))
      crumbs << "tag"
      crumbs << @tags.join("+")
    end
    crumbs << link_to(@command.keyword, command_path(@command)) unless @command.blank? || @command.new_record?
    #used only by help so far
    crumbs << params[:action] if params[:controller] == "static" && params[:action] != "home"
    #crumbs << "<form><input type='text'></input></form>" if nil # !command.blank? && commmand.parametric? && !command.bookmarklet? 
    return crumbs.join(" &raquo; ")
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
end
