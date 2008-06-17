module UserCommandsHelper
  #PERF: won't support sorting for @tags till @tags queries are not so db-intensive
  def sort_link_up(column)
    return '' if @tags
    sort_image = image_tag('icons/arrow-up-triangle.png', :style=>'margin-left: 2px')
    if current_page_matches?(search_user_commands_path)
      link_to sort_image, search_user_commands_path(params.slice(:q).merge(:sort=>"up_by_#{column}"))
    elsif @command && current_page_matches?(command_user_commands_path(@command))
      link_to sort_image, command_user_commands_path(@command, :sort=>"up_by_#{column}")
    elsif @user
      link_to sort_image, specific_user_commands_path(@user, :sort=>"up_by_#{column}")
  	else
      link_to sort_image, user_commands_path(:sort=>"up_by_#{column}")
    end
  end
  
  def sort_link_down(column)
    return '' if @tags
    sort_image = image_tag('icons/arrow-down-triangle.png', :style=>'margin-left: 2px')
    if current_page_matches?(search_user_commands_path)
      link_to sort_image, search_user_commands_path(params.slice(:q).merge(:sort=>"down_by_#{column}"))
  	elsif @command && current_page_matches?(command_user_commands_path(@command))
      link_to sort_image, command_user_commands_path(@command, :sort=>"down_by_#{column}")
    elsif @user
      link_to sort_image, specific_user_commands_path(@user, :sort=>"down_by_#{column}")
    else
      link_to sort_image, user_commands_path(:sort=>"down_by_#{column}")
    end
  end
end
