module ApplicationHelper
  include PathHelper, HeaderHelper, LinkHelper, SharedHelper, TableHelper, TagHelper, AllCommandsHelper
  
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
    
  # Use words if within the last week
  # otherwise use date (show year if not this year)
  def time_ago_in_words_or_date(date)
    return nil unless date
    if (Time.now-date)/60/60/24 < 7
      time_ago_in_words(date) + " ago"
    elsif date.year == Time.now.year
      date.to_s(:short)
    else
      date.to_s(:medium)
    end
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
end
