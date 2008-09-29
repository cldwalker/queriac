#Contains common code between CommandsController and UserCommandsController
#for now just tag related methods
module CommandsControllerHelper
  def parse_tag_input
    return nil, nil unless params[:v]
    keyword_string, tags = params[:v].split(/\s+/, 2)
    keywords = keyword_string.split(',')
    return keywords, tags
  end
  
  def tag_add_remover
    keywords, tag_string = parse_tag_input
  
    successful_commands = []
    unless tag_string.blank?
      #TODO: should move \w+ to a validation regex constant
      remove_list, add_list = tag_string.scan(/-?\w+/).partition {|e| e[0,1] == '-' }
      remove_list.map! {|e| e[1..-1]}
      keywords.each do |n| 
        if (cmd = yield(n))
          cmd.tag_list.add(add_list)
          cmd.tag_list.remove(remove_list)
          cmd.save
          successful_commands << cmd
        end
      end
    end
    render_tag_action(tag_string, keywords, successful_commands)
  end
  
  def tag_setter
    edited_commands = []
    keywords, tag_string = parse_tag_input
    unless tag_string.blank?
      keywords.each do |n| 
        if (cmd = yield(n))
          cmd.update_tags(tag_string)
          edited_commands << cmd
        end
      end
    end
    render_tag_action(tag_string, keywords, edited_commands)
  end
  
  def render_tag_action(tag_string, keywords, successful_commands)
    raise "This action needs to be overridden."
  end
end