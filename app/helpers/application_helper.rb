module ApplicationHelper

  def render_page_title
    if @user || @command || @tag
      crumbs = ["queriac"]
      crumbs << @user.login if @user
      crumbs << "tag" unless @tag.blank?
      crumbs << @tag unless @tag.blank?
      crumbs << @command.keyword unless @command.blank?
      crumbs << "queries" if params[:controller] == "queries"
      return crumbs.join("/")
    else 
      return "Queriac. All our quicksearches are belong to us."
    end
  end
  
  def render_nav
    crumbs = [link_to("queriac", '/')]
    crumbs << link_to(@user.login, @user.home_path) if @user
    crumbs << "commands" unless @tag.blank?
    crumbs << "tag" unless @tag.blank?
    crumbs << @tag.gsub(" ", "+") unless @tag.blank?
    crumbs << link_to(@command.keyword, @command.show_path) unless @command.blank? || @command.new_record?
    crumbs << "queries" if params[:controller] == "queries"
    crumbs << params[:action] if params[:controller] == "static" && params[:action] != "home"
    crumbs << "<form><input type='text'></input></form>" if nil # !command.blank? && commmand.parametric? && !command.bookmarklet? 
    return crumbs.join(" &raquo; ")
  end
  
  def render_mininav
    items = []
    items << "logged in as " + link_to(current_user.login, current_user.home_path, :class => "underlined") if logged_in?
    items << link_to("settings", edit_user_path(current_user.login)) if logged_in?
    items << link_to("tutorial", "/tutorial")
    items << link_to_unless_current("help", "/help")
    items << link_to("logout", session_path(session.id), :confirm => "Are you sure you want to log out?", :method => :delete) if logged_in?
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
    otags.each { |t| tags[t.name] = tags.has_key?(t.name) ? tags[t.name]+1 : 1 }
    
    output = tags.sort.collect{|t| link_to(t[0], "#{@user.tag_path}#{t[0]}", :class => "t#{t[1]}") }.join(" ")
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
  
  def hide(field_id)
    javascript_tag("Element.hide('#{field_id}');")
  end
    
end
