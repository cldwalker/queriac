#contains common code used between commands and user_commands: options, tag and domain related methods
module CommandHelper
  def self.included(base)
    base.class_eval %[
      attr_accessor :query_options; def query_options; @query_options || {} ; end
      def self.url_is_bookmarklet?(url_value)
        url_value.downcase.starts_with?('javascript') ? true : false
      end
      
    ]
  end
  
  #url supports argument and/or option variables
  #option:   google.com?q=(q)&v=[:v]
  #argument: google.com?q=[:1]&v=[:2]
  #options must start at beginning of query
  #option parsing can be turned off by specifying -off
  
  def url_for(query_string, command_options={})
    query = query_string.dup #avoid modifying original string
    #no warning is given for options that aren't valid for a command
    
    @query_options = parse_query_options(query, command_options)
    query.strip!
    
    redirect_url = self.url.gsub(OPTION_PARAM_REGEX) do
      name = $1
      next unless (option = fetch_url_option(name))
       
      #argument
      if name =~ /^\d$/
         value = query_array_value(query, name.to_i) || option.default
      #option
      else
         case option.option_type
         when 'boolean'
           value = @query_options[name] ? option.true_value : option.false_value
         when 'enumerated'
           unaliased_value = option.alias_value(@query_options[name])
           value = option.values_list.include?(unaliased_value) ? @query_options[name] : option.default
         else
           value = @query_options[name] || option.default
         end
       end
       value = option.alias_value(value)
       value = option.prefix_value(value) unless value.blank?
       #TODO: give user option to error out for parameters without value or default
       value = value ? url_encode_string(value, @query_options['url_encode']) : ''
       !option.param.blank? && !value.blank? ? option.param + "=" + value : value
    end
    
    #delete unused '&' leftover from unused
    unless self.bookmarklet? || !has_options?
      redirect_url.gsub!(/&+/,'&')
      redirect_url.sub!(/&$/, '')
      redirect_url.sub!('?&','?')
      redirect_url.sub!(/\?$/, '')
    end
    
    modified_query_string = @query_array ? (@query_array[@biggest_query_array_index .. -1] || []).join(" ") : query
    redirect_url.gsub(DEFAULT_PARAM, url_encode_string(modified_query_string, @query_options['url_encode']))
  end
  
  def fetch_url_option(option_name)
    option_name = option_name.to_s
    @url_options_hash ||= {}
    return @url_options_hash[option_name] if @url_options_hash[option_name]
    (option = Option.find_and_create_by_name(self.url_options, option_name)) ? @url_options_hash[option_name] = option : nil
  end
  
  def options_from_url(url_value=self.url)
    url_value ? url_value.scan(OPTION_PARAM_REGEX).map {|e| e[0] }.uniq : []
  end
  
  def options_from_url_options(url_options_value=self.url_options)
    url_options_value.map {|e| e[:name]}
  end
  
  def query_array_value(query_string, number)
    unless @query_array
      @biggest_query_array_index = 0
      @query_array = query_string.split(/\s+/)
    end
    @biggest_query_array_index = number if number > @biggest_query_array_index
    @query_array[number - 1]
  end
  
  #names/aliases of boolean options
  def url_options_booleans
    url_options.select {|e| e[:option_type] == 'boolean' }.map {|e| [ e[:name], e[:alias]]}.flatten.select {|e| ! e.blank?}
  end
  
  def all_booleans
    url_options_booleans + Option::GLOBAL_BOOLEAN_OPTIONS
  end
  
  def all_options
    options_from_url_options + Option::GLOBAL_OPTIONS
  end
    
  def parse_query_options(query, command_options={})
    options = {}
    #placeholder_for_dollar_1 shouldn't be set, just there to keep $1 constant
    #\b is important otherwise one letter booleans swallow up options starting with same letter
    boolean_regex_string =  all_booleans.empty? ? "-(placeholder_for_dollar_1)|" : "-(#{all_booleans.join('|')})" + '\b|'
    option_regex_string = boolean_regex_string + "-(#{OPTION_NAME_REGEX})" + %q{(\s*=\s*|\s+)?('[^'-]+'|\S+)}
    #-(OPTION_NAME_REGEX)   option is a word
    #(?:\s*=\s*|\s+)    space(s) or '=' delimits option from value
    #(\w+|'[^'-]+')   value can be a word or anything between quotes
    option_regex = Regexp.new option_regex_string
    
    #option parsing starts with '-' unless it's -off
    if query.sub!(/^\s*-off/, '').nil? && query =~ /^\s*-/
      query.gsub!(option_regex) do
        original_string = $~.to_s.dup
        #boolean option set
        if $1
          name = $1
          options[name] = true
        else
          name, value = $2, $4
          #$1 refers to new regexp
          value = $1 if value && value[/^'(.*)'$/]
          options[name] = value
        end
        bool = has_options? || Option::GLOBAL_OPTIONS.include?(name)
        #delete options from query if a global option or an option command
        (has_options? || Option::GLOBAL_OPTIONS.include?(name)) ? '' : original_string
      end
    end
    #auto alias options: match first option from alphabetized options that starts with given name
    #boolean options can't use this
    if command_options[:auto_aliasing]
      sorted_option_names = url_options.map {|e| e[:name]}.sort
      options.delete_if {|name, value|
        if (option = url_options.find {|e| e[:alias] == name})
          options[option[:name]] = value
          true
        elsif !all_options.include?(name) && (option_name = sorted_option_names.find {|e| e.starts_with?(name) })
          options[option_name] = value
          true
        else
          false
        end
      }
    end
      
    #construct hash mapping option aliases to names for both url options and global options
    temp_array = url_options.map {|e| e[:alias] ? [e[:alias], e[:name] ] : []}.flatten
    alias_hash = (Hash[*temp_array]).merge(Option::GLOBAL_OPTION_ALIASES.invert)
    
    #convert aliased name keys to normal option name keys
    options.delete_if {|name, value|
      if (full_name = alias_hash[name])
        options[full_name] = value
        true
      else
        false
      end
    }
    options
  end
  
  def has_options?
    (self.url =~ OPTION_PARAM_REGEX ? true : false) && !url_options.blank?
  end
  
  def ordered_url_options(unordered_options=self.url_options, ordered_url=self.url)
    ordered_option_names = options_from_url(ordered_url)
    ordered_options = []
    ordered_option_names.each do |e|
      if (option = Option.find_and_create_by_name(unordered_options, e))
        ordered_options << option
      end
    end
    ordered_options
  end
  
  def url_encode_string(string, manual_url_encode=nil)
    is_url_encoded = !manual_url_encode.nil? ? manual_url_encode == '1': url_encode?
    is_url_encoded ? CGI.escape(string) : string
  end
  
  def url_options=(value)
    value = Option.sanitize_input(value || [])
    #to preserve nil value when there are no options
    value = nil if value.is_a?(Array) && value.empty?
    super(value)
  end
  
  def url_options
    read_attribute(:url_options) || []
  end
  
  def validate_url_options
    #should go before url + url options sync
    name_regex = "^#{OPTION_NAME_REGEX}$"
    invalid_option_names = url_options.reject {|e| e[:name] =~ /#{name_regex}/ && (e[:alias] ? e[:alias] =~ /#{name_regex}/ : true)}.map {|e| e[:name]}
    unless invalid_option_names.empty?
      errors.add(:url_options, "has invalid option names. Names should only contain alphanumeric characters." +
        "The following option(s) are invalid: #{invalid_option_names.join(', ')}.")
    end
    
    #options from url + url_options column match
    if options_from_url.sort != options_from_url_options.sort
      missing = options_from_url - options_from_url_options
      extra = options_from_url_options - options_from_url
      message = "don't match options defined by url."
      message += " Extra option(s) are #{extra.join(", ")}." unless extra.empty?
      message += " Missing option(s) are #{missing.join(", ")}." unless missing.empty?
      errors.add(:url_options, message)
    end
    
    #option names + aliases must be unique
    option_names = url_options.map {|e| [e[:name], e[:alias]]}.flatten.delete_if{|e| e.blank? }
    duplicates = duplicates_in_array(option_names)
    errors.add(:url_options, "has the following duplicate option names/aliases: #{duplicates.join(", ")}.") unless duplicates.empty?
    
    unless self.user && self.user.is_admin?
      #field lengths must not exceed field_length_max
      #might need longer length for values and description fields
      field_length_max = Option::FIELD_LENGTH_MAX
      options_with_long_fields = url_options.select {|e| e.values.any?{|f| f.length > field_length_max} }.map {|e| e[:name]}
      unless options_with_long_fields.empty?
        errors.add(:url_options, "has the following options with fields longer than #{field_length_max} characters: #{options_with_long_fields.join(", ")}") 
      end
    end
    
    #quicksearches shouldn't contain illegal characters ie '&' in their data fields
    if url_is_bookmarklet?(self.url)
      options_with_illegal_characters = url_options.select {|e| e.except(:name, :description, :option_type).values.any?{|f| f.include?('&')} }.map {|e| e[:name]}
      unless options_with_illegal_characters.empty?
        errors.add(:url_options, "has the following options with illegal characters('&') in data fields: #{options_with_illegal_characters.join(', ')}") 
      end
    end
    
    #max number of allowed options
    max_number_of_options = Option::MAX_OPTIONS
    if url_options.size > max_number_of_options 
      errors.add(:url_options, "has exceeded the number of allowed options (#{max_number_of_options}).")
    end
    
    #reserved names for global options
    global_option_names = (options_from_url_options + url_options.map {|e| e[:alias]}) & Option::GLOBAL_OPTIONS
    unless global_option_names.empty?
      errors.add(:url_options, "has the following option(s) with names/aliases that are reserved for internal use: #{global_option_names.join(', ')}")
    end
    
  end
  
  def duplicates_in_array(array)
    count = {}
    array.each {|e|
      count[e] ||= 0
      count[e] += 1
    }
    count.delete_if {|k,v| v<=1}
    count.keys
  end
  
  def url_is_bookmarklet?(url_value)
    self.class.url_is_bookmarklet?(url_value)
  end
  
  def public_queries?; self.public && self.public_queries; end
  
  #domain value should be the same for command + its usercommand
  #pushing to have no dependence on command when rendering favicons
  def domain
    @domain ||= get_domain
  end
  
  def get_domain
    # Found the regex at http://yubnub.org/kernel/man?args=extractdomainname
    u = url.dup
    if bookmarklet?
      return nil if url.split("http").size == 1
      u = "http" + url.split("http").last
    end
    
    #if has options
    u.gsub!(OPTION_PARAM_REGEX) do
      name = $1
      next unless (option = fetch_url_option(name))
      option.default || ''
    end
    
    u=~(/^(?:\w+:\/\/)?([^\/?]+)(?:\/|\?|$)/) ? $1 : nil
  end
  
  def favicon_url
    return "/images/icons/blank_bordered.png" if domain.nil?
    "http://#{domain}/favicon.ico"
  end
  
  #for now loads up command
  #must be a type that is in Command::TYPES (these are singular versions of them)
  def command_type
    if has_options?
      "option"
    elsif bookmarklet?
      "bookmarklet"
    elsif parametric?
      "quicksearch"
    else
      "shortcut"
    end
  end
  
  def update_tags(tags)
    self.tag_list = tags.split(" ").join(", ")
    self.save
  end
  
  def tag_string
    self.tag_list.join(" ")
  end
end