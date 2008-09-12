#for methods used both by commands and user commands
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
end