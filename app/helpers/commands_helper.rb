module CommandsHelper
  def sort_link_up(column)
    link_to image_tag('icons/arrow-up-triangle.png', :style=>'margin-left: 2px'), commands_path(:sort=>"up_by_#{column}")
  end
  
  def sort_link_down(column)
    link_to image_tag('icons/arrow-down-triangle.png', :style=>'margin-left: 2px'), commands_path(:sort=>"down_by_#{column}")
  end
end
