module TagHelper
  def tag_cloud(otags)
    output = count_tags_by_name(otags).sort.collect{ |name, num|
      opacity = (50 + [num, 10].min.to_f/2*10).to_f/100
      font_size = (80 + [num, 20].min.to_f*5).to_f
      link_to("#{name}", tagged_user_commands_path(@user, name), :title => "#{name} (#{num})", :style => "opacity:#{opacity};font-size:#{font_size}%;") 
    }.join(" ")
    content_tag(:p, output, :class => "tags")
  end
  
  def count_tags_by_name(otags)
    unless @tags_by_name
      @tags_by_name = {}
      otags.each { |t| @tags_by_name[t.name] = @tags_by_name.has_key?(t.name) ? @tags_by_name[t.name]+1 : 1 }
    end
    @tags_by_name
  end
  
  def tag_list(otags)
    #group tag names by tag count
    tags_by_number = {}
    count_tags_by_name(otags).each {|k,v| tags_by_number[v] ||= []; tags_by_number[v] << k }
    tags_by_number = tags_by_number.sort {|a,b| b[0] <=> a[0]}
    
    content_tag(:ul, :class=>'normal') do
      tags_by_number.map do |tag_count, tag_names|
        tags = tag_names.map {|e| link_to(e, tagged_user_commands_path(@user, e))}.join(", ")
        content_tag(:li, "#{tag_count}: #{tags}", :class=>'normal')
      end.join("\n")
    end
  end
  
  def tag_cloud_or_list(tags, options={})
    options.reverse_merge!(:link_options => {})
    list_link = link_to_function('List', "this.up('div').next().show(); this.up('div').hide()", options[:link_options])
    cloud_text = content_tag(:h3, "Cloud | #{list_link}", :style=>"margin-bottom: 10px") + tag_cloud(tags)
    cloud_link = link_to_function('Cloud', "this.up('div').previous().show(); this.up('div').hide()", options[:link_options])
    list_text =  content_tag(:h3, "#{cloud_link} | List", :style=>"margin-bottom: 10px") + tag_list(tags)
    all_text = content_tag(:div, cloud_text) + content_tag(:div, list_text, :style => 'display:none;')
  end
end