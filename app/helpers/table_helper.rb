module TableHelper
  
  def user_command_column_value(user_command, column)
    case column
    when :user
        link_to user_command.user.login, user_home_path(user_command.user)
    when :name
      render_favicon_for_command(user_command) + " " + link_to(user_command.name, public_user_command_path(user_command))
    when :queries_count
      user_command.queries_count
    else
      ''
    end
  end
  
  def user_command_table(user_commands, options={})
    options = {:columns=>[:user, :name, :queries_count]}.merge(options)
    default_headers = {:user=>'User', :name=>'User Command', :queries_count=>'Queries'}
    options[:headers] = options[:columns].map {|c| default_headers[c] || c.humanize }
    active_record_table(user_commands, options)
  end
  
  def query_column_value(query, column)
    case column
    when :user
      query_user(query)
    when :query_string
      link_to_query query
    when :user_command
      render_favicon_for_command(query.user_command) + " " + 
        link_to(query.user_command.name, public_user_command_path(query.user_command))
    when :created_at
	    time_ago_in_words_or_date query.created_at
	  end
  end
  
  def query_table(queries, options={})
    options.reverse_merge! :columns=>[:query_string, :created_at]
    default_headers = {:query_string=>'Query', :created_at=>'Date', :user=>'User', :user_command=>'User Command'}
    options[:headers] = options[:columns].map {|c| default_headers[c] || c.to_s.humanize }
    active_record_table(queries, options)
  end
  
  def active_record_table(ar_collection, options={})
    options[:table] ||= {}
    options[:headers] ||= options[:columns].map {|c| c.to_s.humanize }
    content_tag(:table, options[:table]) do
      headers = content_tag(:tr) do
        options[:headers].map {|e| content_tag(:th, *e)}.join("\n")
      end
      
      body = ar_collection.map do |uc|
        content_tag(:tr, :class=>cycle('offset', '')) do
          options[:columns].map do |c|
            content_tag(:td, send("#{ar_collection[0].class.to_s.underscore}_column_value", uc, c))
          end.join("\n")
        end
      end.join("\n")
      
      headers + "\n" + body
    end
  end
  
  def option_column_value(option, column)
    if column  == :others
      others = []
      case option.option_type
      when 'boolean'
        others << "True Value: #{option.true_value}" unless option.true_value.blank?
      when 'enumerated'
        if option.values_hash
          others << truncate_with_more("Values: #{option.values_hash.keys.join(', ')}", nil, :tag_type=>'span') unless option.values_hash.blank?
          others << truncate_with_more("Values with labels: #{option.values_hash.map {|k,v| k + (v ? "(#{v})" : '')}.join(', ')}", nil,:tag_type=>'span') unless option.values_hash.blank?
        else
          others << truncate_with_more("Values: #{option.values_array.join(', ')}",nil, :tag_type=>'span') unless option.values_array.blank?
        end
        others << "Default: #{option.default}" unless option.default.blank?
      else
        others << "Value: #{option.value}" unless option.value.blank?
      end
      others << "Label: #{option.label}" unless option.label.blank?
      content_tag(:ul, :style=>"list-style-type: disc; list-style-position: inside") do
        others.map {|e| content_tag(:li, e)}
      end
    else
      option.send(column)
    end
  end
  
  def table_link_to(name, options={}, html_options={})
    html_options[:class] ||= 'faded'
    content_tag(:p, link_to(name, options, html_options))
  end
  
end