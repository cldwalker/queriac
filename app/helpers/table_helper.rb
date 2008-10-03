module TableHelper
  
  def user_command_column_value(user_command, column)
    case column
    when :user
        user_link(user_command.user)
    when :name
      user_command_link(user_command)
    when :name_bolded
      content_tag(:p, user_command_link(user_command), :class=>'command_title') + 
      content_tag(:p, %[Tags #{user_command.tags.map{|t| link_to(t.name, tagged_user_commands_path(user_command.user,t.name)) }.join(" ")}], :class=>'tag_list')
    when :queries_count
      klass = user_command.queries_count == 0 ? "centered faded" : "centered"
      [user_command.queries_count, {:class=>klass}]
    when :url_status
      url_status(user_command, :status_length=>25)
    when :command_bolded
      content_tag(:p, basic_command_link(user_command.command), :class=>'command_title')
    when :command
      basic_command_link user_command.command
    when :keyword
      [user_command.keyword, {:class=>'centered'}]
    when :created_at
      time_ago_in_words_or_date(user_command.created_at, :short=>true)
    when :command_actions
      user_command_actions(user_command)
    else
      ''
    end
  end
  
  def user_command_table(user_commands, options={})
    options = {:columns=>[:user, :name, :queries_count]}.merge(options)
    default_headers = {:user=>'User', :name=>'User Command', :queries_count=>'Queries'}
    options[:headers] ||= options[:columns].map {|c| default_headers[c] || c.to_s.humanize }
    active_record_table(user_commands, options)
  end
  
  def command_column_value(command, column)
    case column
    when :name
      command_link(command)
    when :name_bolded
      content_tag(:p, command_link(command), :class=>'command_title')
    when :user
      user_link(command.user)
    when :users_count
      [command.users_count, {:class=>'centered'}]
    when :queries_count
      klass = command.queries_count_all == 0 ? "centered faded" : "centered"
      [command.queries_count_all, {:class=>klass}]
    when :keyword
      [command.keyword, {:class=>'centered'}]
    when :created_at
      time_ago_in_words_or_date(command.created_at, :short=>true)
    when :revised_at
      time_ago_in_words_or_date(command.revised_at, :short=>true) || '--'
    when :command_actions
      command_actions(command)
    end
  end
  
  def command_table(commands, options={})
    options = {:columns=>[:name, :user, :created_at]}.merge(options)
    default_headers = {:user=>'Creator', :name=>'Command', :queries_count=>'Queries'}
    options[:headers] ||= options[:columns].map {|c| default_headers[c] || c.to_s.humanize }
    active_record_table(commands, options)
  end
  
  def query_column_value(query, column)
    case column
    when :user
      query_user(query)
    when :command_icon
      link_to(render_favicon_for_command(query.user_command), public_user_command_path(query.user_command))
    when :query_string
      link_to_query query
    when :user_command
      user_command_link(query.user_command)
    when :created_at
	    time_ago_in_words_or_date query.created_at
	  end
  end
  
  def query_table(queries, options={})
    options.reverse_merge! :columns=>[:query_string, :created_at]
    default_headers = {:query_string=>'Query', :created_at=>'Date', :user=>'User', :user_command=>'User Command'}
    options[:headers] ||= options[:columns].map {|c| default_headers[c] || c.to_s.humanize }
    active_record_table(queries, options)
  end
  
  #build tables with the following options:
  # :headers - override default, takes array of header values (which can be a string or array)
     #if header value is array, the second array element is a hash to specifies attributes for td tag
  # :columns - specify symbol keys used by *_column_value() methods to map to columns
  # :table - constructs attributes for table tag
  def active_record_table(ar_collection, options={})
    options[:table] ||= {}
    options[:headers] ||= options[:columns].map {|c| c.to_s.humanize }
    content_tag(:table, options[:table]) do
      headers = content_tag(:tr) do
        options[:headers].map {|e| e = e.to_a; content_tag(:th, e[0], e[1])}.join("\n")
      end
      
      body = ar_collection.map do |uc|
        content_tag(:tr, :class=>cycle('offset', '')) do
          options[:columns].map do |c|
            td_content = send("#{ar_collection[0].class.to_s.underscore}_column_value", uc, c).to_a
            content_tag(:td, td_content[0], td_content[1])
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
        others << "True Value: #{h option.true_value}" unless option.true_value.blank?
      when 'enumerated'
        if option.values.blank?
          others << "No valid values"
        else
          others << truncate_with_more("Values: #{h option.values}",nil, :tag_type=>'span')
          others << truncate_with_more("Values with labels: #{h option.annotated_values}", nil,:tag_type=>'span') unless option.values_hash.blank? || option.annotated_values == option.values
        end
        others << [truncate_with_more("Note: #{h option.note}",nil,:tag_type=>'span'), {:style=>'padding-left: 20px; font-style: italic'}] unless option.note.blank?
        others << "Default: #{h option.default}" unless option.default.blank?
      else
        others << "Value: #{h option.value}" unless option.value.blank?
      end
      others << "Description: #{h option.description}" unless option.description.blank?
      content_tag(:ul, :style=>"list-style-type: disc; list-style-position: inside") do
        others.map {|e| 
          e = e.to_a
          content_tag(:li, e[0], e[1])
        }
      end
    else
      option.send(column)
    end
  end
  
  def table_link_to(name, options={}, html_options={})
    content_tag(:p, link_to(name, options, :class=>'faded'), html_options)
  end
  
end