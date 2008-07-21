#contains common code used between commands and user_commands: options and domain related methods
module CommandHelper
  
  #url supports argument and/or option variables
  #option:   google.com?q=(q)&v=[:v]
  #argument: google.com?q=[:1]&v=[:2]
  #options must start at beginning of query
  #option parsing can be turned off by specifying -off
  
  def url_for(query_string, manual_url_encode=nil)
    query = query_string.dup #avoid modifying original string
    #no warning is given for options that aren't valid for a command
    query_options = parse_query_options(query)
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
           value = query_options[name] ? option.true_value : option.false_value
         when 'enumerated'
           value = option.alias_value(query_options[name])
           value = option.values_list.include?(value) ? value : option.default
         else
           value = query_options[name] ? option.alias_value(query_options[name]) : option.default
         end
       end
       value = option.prefix_value(value)
       #TODO: give user option to error out for parameters without value or default
       value ? url_encode_string(value) : ''
    end
    
    modified_query_string = @query_array ? (@query_array[@biggest_query_array_index .. -1] || []).join(" ") : query
    redirect_url.gsub(DEFAULT_PARAM, url_encode_string(modified_query_string))
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
    
  def parse_query_options(query)
    options = {}
    #placeholder_for_dollar_1 shouldn't be set, just there to keep $1 constant
    boolean_regex_string =  url_options_booleans.empty? ? "-(placeholder_for_dollar_1)|" : "-(#{url_options_booleans.join('|')})|"
    option_regex_string = boolean_regex_string + %q{-(\w+)(\s*=\s*|\s+)?(\w+|'[^'-]+')}
    #-(\w+)             option is a word, should match option regex in OPTION_PARAM_REGEX
    #(?:\s*=\s*|\s+)    space(s) or '=' delimits option from value
    #(\w+|'[^'-]+')   value can be a word or anything between quotes
    option_regex = Regexp.new option_regex_string
    
    #option parsing starts with '-' unless it's -off
    if query.sub!(/^\s*-off/, '').nil? && query =~ /^\s*-/
      query.gsub!(option_regex) do
        #boolean option set
        if $1
          options[$1] = true
        else
          name, value = $2, $4
          #$1 refers to new regexp
          value = $1 if value && value[/^'(.*)'$/]
          options[name] = value
        end
        ''
      end
    end
    #convert aliased names to normal option names
    options.delete_if {|name, value|
      #merge with fetch_url_option if this is done again
      if (option = url_options.find {|e| e[:alias] == name})
        options[option[:name]] = value
        true
      else
        false
      end
    }
    options
  end
  
  def has_options?
    self.url =~ OPTION_PARAM_REGEX ? true : false
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
    is_url_encoded = !manual_url_encode.nil? ? manual_url_encode : url_encode?
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
    
    #field lengths must not exceed field_length_max
    #might need longer length for values and description fields
    field_length_max = 350
    options_with_long_fields = url_options.select {|e| e.values.any?{|f| f.length > field_length_max} }.map {|e| e[:name]}
    unless options_with_long_fields.empty?
      errors.add(:url_options, "has the following options with fields longer than #{field_length_max} characters: #{options_with_long_fields.join(", ")}") 
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
  
end

__END__

# def simple_url_for(query_string, manual_url_encode=nil)
#   is_url_encoded = !manual_url_encode.nil? ? manual_url_encode : url_encode?
#   if is_url_encoded
#     self.url.gsub(DEFAULT_PARAM, CGI.escape(query_string))
#   else
#     self.url.gsub(DEFAULT_PARAM,query_string)
#   end
# end


#TODO: escape characters used in regexs ie value[/[^\\]\|/]
# def old_url_for(query_string, manual_url_encode=nil)
#   #no warning is given for options that aren't valid for a command
#   options = parse_query_options(query_string)
#   query_string.strip!
#   
#   #OPTION_PARAM_REGEX = /\[:(\w+)(=[^\[\]]+)?\]/
#   redirect_url = self.url.gsub(OPTION_PARAM_REGEX) do
#     name = $1
#     default = $2 ? $2[1..-1] : nil
#      
#      #position value
#      if name =~ /^\d$/
#        value = query_array_value(query_string, name.to_i) || default
#       #option value
#      else
#        #boolean option detected
#        if default && default.include?("|")
#          true_value, false_value = default.split("|", 2)
#          value = options[name] ? true_value : false_value
#        #enumerated option detected
#        elsif default && default.include?(",")
#          possible_values = default.split(",")
#          value = possible_values.include?(options[name]) ? options[name] : possible_values[0]
#        else
#          value = options[name] || default
#        end
#      end
#      
#      # p [name, default]
#      #TODO: give user option to error out for parameters without value or default
#      value ? url_encode_string(value) : ''
#   end
#   
#   redirect_url.gsub(DEFAULT_PARAM, url_encode_string(query_string))
# end

# def extract_url_options
#     uoptions = {}
#     self.url.scan(OPTION_PARAM_REGEX).each do |e|
#       name = e[0].to_sym
#       default = e[1] ? e[1][1..-1] : nil
#        #position value
#       if name =~ /^\d$/
#          #do nothing
#       #option value
#       else
#          #boolean option detected
#          if default && default.include?("|")
#            true_value, false_value = default.split("|", 2)
#            uoptions[name] = {:type=>:boolean, :true=>true_value, :false=>false_value}
#            
#          #enumerated option detected
#          elsif default && default.include?(",")
#            possible_values = default.split(",")
#            uoptions[name] = {:type=>:enumerated, :values=>possible_values, :default=>possible_values[0]}
#          else
#            uoptions[name] = default.nil? ? {} : {:default=>default}
#          end
#        end
#     end
#     uoptions   
#   end
#   
# def alias_option_value(option_value, alias_definition='')
#   alias_definition.include?(":") && (alias_definition.split(":")[0] == option_value) ? alias_definition.split(":")[1] : option_value
# end

