module CommandsHelper
  def sort_link_up(column)
    sort_image = image_tag('icons/arrow_up.png', :style=>'margin-left: 2px')
    sort_params = {:sort=>"up_by_#{column}"}
    if current_page_matches?(search_all_commands_path)
      nofollow_link_to sort_image, search_all_commands_path(params.slice(:q, :type).merge(sort_params))
    elsif params[:type] && current_page_matches?(command_type_commands_path(params[:type]))
      nofollow_link_to sort_image, command_type_commands_path(params.slice(:type).merge(sort_params))
  	else
      nofollow_link_to sort_image, commands_path(sort_params)
    end
  end
  
  def sort_link_down(column)
    sort_image = image_tag('icons/arrow_down.png', :style=>'margin-left: 2px')
    sort_params = {:sort=>"down_by_#{column}"}
    if current_page_matches?(search_all_commands_path)
      nofollow_link_to sort_image, search_all_commands_path(params.slice(:q, :type).merge(sort_params))
    elsif params[:type] && current_page_matches?(command_type_commands_path(params[:type]))
      nofollow_link_to sort_image, command_type_commands_path(params.slice(:type).merge(sort_params))
  	else
      nofollow_link_to sort_image, commands_path(sort_params)
    end
  end
end
