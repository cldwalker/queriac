module TagHelper
  #tag_cloud() conflicts with taggable plugin
  def my_tag_cloud(otags, options={})
    name_count_hash = otags.is_a?(Hash) ? otags : count_tags_by_name(otags)
    max_count = name_count_hash.values.sort.last.to_f
    output = name_count_hash.sort.collect{ |name, num|
      opacity = (50 + [num, 10].min.to_f/2*10).to_f/100
      #old way didn't work for datasets with many high numbers since it didn't
      #weigh a count in relation to others but simply against a scale of 1 to 20
      #old way: font_size = (80 + [num, 20].min.to_f*5).to_f
      font_size = (80 + (num / max_count).to_f * 100).to_f
      tag_link_to(name, options[:path], :title => "#{name} (#{num})", :style => "opacity:#{opacity};font-size:#{font_size}%;")
    }.join(" ")
    content_tag(:p, output, :class => "tags")
  end
  
  def tag_link_to(name, path_type, html_options = nil, *parameters_for_method_reference)
    path = case path_type
    when :all_users
       all_tagged_user_commands_path(name)
    when :command
      tagged_commands_path(name)
    else
      @user ? tagged_user_commands_path(@user, name) : '#'
        
    end
    link_to(name, path, html_options, *parameters_for_method_reference)
  end
  
  def count_tags_by_name(otags)
    unless @tags_by_name
      @tags_by_name = {}
      otags.each { |t| @tags_by_name[t.name] = @tags_by_name.has_key?(t.name) ? @tags_by_name[t.name]+1 : 1 }
    end
    @tags_by_name
  end
  
  def tag_list(otags,options={})
    name_count_hash = otags.is_a?(Hash) ? otags : count_tags_by_name(otags)
    #group tag names by tag count
    tags_by_number = {}
    name_count_hash.each {|k,v| tags_by_number[v] ||= []; tags_by_number[v] << k }
    tags_by_number = tags_by_number.sort {|a,b| b[0] <=> a[0]}
    
    content_tag(:ul, :class=>'normal') do
      tags_by_number.map do |tag_count, tag_names|
        tags = tag_names.map {|e| tag_link_to(e,options[:path])}.join(", ")
        content_tag(:li, "#{tag_count}: #{tags}", :class=>'normal')
      end.join("\n")
    end
  end
  
  def tag_cloud_or_list(tags, options={})
    options.reverse_merge!(:link_options => {})
    list_link = link_to_function('List', "this.up('div').next().show(); this.up('div').hide()", options[:link_options])
    cloud_text = content_tag(:h3, "Cloud | #{list_link}", :style=>"margin-bottom: 10px") + my_tag_cloud(tags, options)
    cloud_link = link_to_function('Cloud', "this.up('div').previous().show(); this.up('div').hide()", options[:link_options])
    list_text =  content_tag(:h3, "#{cloud_link} | List", :style=>"margin-bottom: 10px") + tag_list(tags, options)
    all_text = content_tag(:div, cloud_text) + content_tag(:div, list_text, :style => 'display:none;')
  end
end