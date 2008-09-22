#global methods used both by commands and/or user commands
module AllCommandsHelper
  def whose_commands(command)
    command.user == current_user ? "Your" : "#{@user.login}'s public"
  end

  def render_favicon_for_command(command)
    image_tag(command.favicon_url, :alt => "", :width => "16", :height => "16")
  end
  
  def sort_description
    direction, preposition, column = params[:sort].scan(/^([a-z]+)_([a-z]+)_(.*)$/).flatten
    return '' unless @controller.valid_sort_columns.include?(column)
    #chopping off first word in underscored column ie created_at -> created and queries_sort-> queries
    column = column[/[a-z]+/]
    "sorted #{direction} #{preposition} #{column}"
  end
  
  def command_description(command)
    simple_format command.description.blank? ? 'No description yet.' : command.description
  end
  
  #:show_private option is used to override option privacy for command owners and admins
  def option_metadata(option, options={})
    metadata = []
    metadata << "param: #{h option.param}" unless option.param.blank?
    metadata << "description: #{h option.description}" unless option.description.blank?
		metadata << "allowed values: #{truncate_with_more h(option.sorted_values), 70, :tag_type=>'span'}" unless option.values.blank?
		if option.option_type == 'boolean'
  		metadata << "true value: #{h option.true_value}" unless option.true_value.blank?
  		metadata << "false value: #{h option.false_value}" unless option.false_value.blank?
  	else
  		metadata << "default: #{h option.default}" if !option.default.blank? && (options[:show_private] || option.public?)
  	end
		metadata << "alias: #{h option.alias}" unless option.alias.blank?
		metadata << "value prefix: #{h option.value_prefix}" unless option.value_prefix.blank?
	  metadata << "value aliases: #{h option.value_aliases}" if !option.value_aliases.blank? && (options[:show_private] || option.public?)
  	metadata << "private: true" if option.private? if options[:show_private]
		
		return '' if metadata.empty?
		content_tag(:ul) do
		  metadata.map {|e| content_tag(:li, e, :style=>'margin: 0px 0px 2px 0px')}.join("\n")
		end
  end  
  
  def url_status(user_command, html_options={})
    html_options.reverse_merge(:status_length=>100)
    content_tag(:span, {:id=>'url_status'}.update(html_options)) do
		  if user_command.command_url_changed?
		    if user_command_owner?(user_command)
  		    %[Not up to date.<br/>
  		      The command's url has changed to: #{truncate_with_more(h(user_command.command.url), html_options[:status_length], :tag_type=>'span')}<br/>] +
  		      link_to_remote('Click to update url and options', :url=>update_url_user_command_path(user_command),
  		      :before=>"$('url_status_spinner').show()", :complete=>"$('url_status_spinner').hide()")  + ajax_spinner('url_status')
		    else
		      "Not up to date"
		    end
		  else
			  "Up to date"
		  end
		end
  end
  
  def user_command_actions(ucommand, options={})
    options.reverse_merge!(:class=>'options')
    content_tag(:ul, :class=>options[:class]) do
      body = ''
		  if ucommand.owned_by?(current_user)
		    if options[:action]
		      if options[:action] == 'edit'
            body += content_tag(:li, link_to("Show", public_user_command_path(ucommand)), :class=>'search')
          elsif options[:action] == 'show'
            body += content_tag(:li, link_to("Edit", edit_user_command_path(ucommand)), :class=>'edit')
          end
          body += content_tag(:li, link_to("Delete", user_command_path(ucommand), 
            :confirm => "Are you sure you want to delete this command?", :method=>:delete), :class=>'delete')
        else
          body += content_tag(:li, link_to(image_tag("icons/edit.png"), edit_user_command_path(ucommand)), :class=>'no_icon')
          body += content_tag(:li, link_to(image_tag("icons/delete.png"), user_command_path(ucommand), 
            :confirm => "Are you sure you want to delete this command?", :method=>:delete), :class=>'no_icon')
        end
		  elsif logged_in?
		    body = ''
		    if options[:with_copy]
		      body += content_tag(:li, link_to('Copy', copy_user_command_path(ucommand)), :class=>'add')
		    end
  			body += content_tag(:li, link_to('Subscribe', subscribe_user_command_path(ucommand)), :class=>'add')
	    end
	    body
	  end
  end
  
  def command_actions(command)
		content_tag(:ul, :class=>'options') do
		  body = ''
		  if current_user.is_admin?
		    body += content_tag(:li, link_to(image_tag("icons/edit.png"), edit_command_path(command)), :class=>'no_icon')
		  end
		  unless command.created_by?(current_user)
		    body += content_tag(:li, link_to('Subscribe', subscribe_user_command_path(:id=> command.id, :is_command=>true)), :class=>'add' )
		  end
		  body
		end
  end
  
  def command_type_title(command_type)
    title_hash = {  
      :options=>"Commands that have command options and/or multiple arguments. Think of these as more complex quicksearches",
      :bookmarklets=>"Commands that use javascript. Your Queriac Bookmarklet Enabler must come before these commands. See http://queri.ac/tutorial#bookmarklets",
      :shortcuts=>"Commands that are shortcuts to a webpage.",
      :quicksearches=>"Commands that take one argument. They are used mainly for searching websites."
    }
    title_hash[command_type.to_sym]
  end
  
  def command_type_image(command_type)
    image_hash = {:options=>"star.png", :bookmarklets=>"bookmarklet.png", :shortcuts=>"shortcut.png", :quicksearches=>"search.png"}
    command_type = command_type.to_sym
    if image_hash[command_type]
      image_tag("icons/#{image_hash[command_type]}", :title=>command_type_title(command_type))
    end
  end
end