module CommandsHelper
  def sort_link_up(column)
    sort_image = image_tag('icons/arrow-up-triangle.png', :style=>'margin-left: 2px')
    if current_page_matches?(search_all_commands_path)
      nofollow_link_to sort_image, search_all_commands_path(params.slice(:q).merge(:sort=>"up_by_#{column}"))
  	else
      nofollow_link_to sort_image, commands_path(:sort=>"up_by_#{column}")
    end
  end
  
  def sort_link_down(column)
    sort_image = image_tag('icons/arrow-down-triangle.png', :style=>'margin-left: 2px')
    if current_page_matches?(search_all_commands_path)
      nofollow_link_to sort_image, search_all_commands_path(params.slice(:q).merge(:sort=>"down_by_#{column}"))
  	else
      nofollow_link_to sort_image, commands_path(:sort=>"down_by_#{column}")
    end
  end
end
