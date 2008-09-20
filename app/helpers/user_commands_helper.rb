module UserCommandsHelper
  #PERF: won't support sorting for @tags till @tags queries are not so db-intensive
  def sort_link_up(column)
    return '' if @tags
    sort_image = image_tag('icons/arrow_up.png', :style=>'margin-left: 2px')
    if current_page_matches?(search_user_commands_path)
      nofollow_link_to sort_image, search_user_commands_path(params.slice(:q).merge(:sort=>"up_by_#{column}"))
    elsif @command && current_page_matches?(command_user_commands_path(@command))
      nofollow_link_to sort_image, command_user_commands_path(@command, :sort=>"up_by_#{column}")
    elsif @user && current_page_matches?(specific_user_commands_path(@user))
      nofollow_link_to sort_image, specific_user_commands_path(@user, :sort=>"up_by_#{column}")
  	else
      nofollow_link_to sort_image, user_commands_path(:sort=>"up_by_#{column}")
    end
  end
  
  def sort_link_down(column)
    return '' if @tags
    sort_image = image_tag('icons/arrow_down.png', :style=>'margin-left: 2px')
    if current_page_matches?(search_user_commands_path)
      nofollow_link_to sort_image, search_user_commands_path(params.slice(:q).merge(:sort=>"down_by_#{column}"))
  	elsif @command && current_page_matches?(command_user_commands_path(@command))
      nofollow_link_to sort_image, command_user_commands_path(@command, :sort=>"down_by_#{column}")
    elsif @user && current_page_matches?(specific_user_commands_path(@user))
      nofollow_link_to sort_image, specific_user_commands_path(@user, :sort=>"down_by_#{column}")
    else
      nofollow_link_to sort_image, user_commands_path(:sort=>"down_by_#{column}")
    end
  end
  
  def option_type_specific_fields(option_type, form, options={})
    fields = ''
    case option_type
    when 'enumerated'
      fields += content_tag(:div, :class=>'floater') do
        text_field_id = "user_command_url_options_#{options[:index]}_values"
        update_link = link_to_remote("Update Default", :url=>update_default_picker_user_commands_path(:index=>options[:index]),
          :with=>"'values=' + escape($('#{text_field_id}').value)", :before=>"$('enumerated_#{options[:index]}_spinner').show()",
          :complete=>"$('enumerated_#{options[:index]}_spinner').hide()")
        label_tag(text_field_id, %[Values (comma delimited) #{update_link}]) +
          "<br/>" + form.text_area(:values, :cols=>30, :rows=>2, :wrap=>'virtual') + ajax_spinner("enumerated_#{options[:index]}")
      end 
      fields += content_tag(:div, :class=>'floater') do
        values_array = options[:option_obj] ? options[:option_obj].sorted_annotated_values_list : []
        form.label(:default) + "<br/>" +  form.select(:default, values_array, {:include_blank=>true}, :index=>options[:index])
      end
      fields += content_tag(:div, nil, :class=>'floatkiller')
    when 'boolean'
      fields << content_tag(:div, :class=>'floater') do
        form.label(:true_value) + "<br/>" + form.text_field(:true_value, :size=>20)
      end
      fields << content_tag(:div, :class=>'floater') do
        form.label(:false_value) + "<br/>" + form.text_field(:false_value, :size=>20)
      end
    else
      fields += content_tag(:div, :class=>'floater') do
        form.label(:default) + "<br/>" + form.text_field(:default, :size=>20)
      end
    end
    fields
  end  
end
