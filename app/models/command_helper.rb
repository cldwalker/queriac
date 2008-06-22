module CommandHelper
  
  #url supports position and/or option variables with defaults
  #option:   google.com?q=(q)&v=[:v=normal]
  #position: google.com?q=[:1]&v=[:2]
  #options must start at beginning of query
  #option parsing can be turned off by specifying -off
  def url_for(query_string, manual_url_encode=nil)
    #no warning is given for options that aren't valid for a command
    options = parse_query_options(query_string)
    query_string.strip!
    
    #OPTION_PARAM_REGEX = /\[:(\w+)(=[^\[\]]+)?\]/
    redirect_url = self.url.gsub(OPTION_PARAM_REGEX) do
      name = $1
      default = $2 ? $2[1..-1] : nil
       
       #position value
       if name =~ /^\d$/
         value = query_array_value(query_string, name.to_i)
        #option value
       else
         value = options[name]
       end
       # p [name, default]
       value ||= default
       #TODO: give user option to error out for parameters without value or default
       value ? url_encode_string(value) : ''
    end
    
    redirect_url.gsub(DEFAULT_PARAM, url_encode_string(query_string))
  end
  
  def query_array_value(query_string, number)
    unless @query_array
      @query_array = query_string.split(/\s+/)
    end
    @query_array[number - 1]
  end
  
  def parse_query_options(query_string)
    options = {}
    option_regex = /-(\w+)(\s*=\s*|\s+)?(\w+|'[^'-]+')?/
    #-(\w+)             option is a word, should match option regex in OPTION_PARAM_REGEX
    #(?:\s*=\s*|\s+)    space(s) or '=' delimits option from value
    #(\w+|'[^'-]+')   value can be a word or anything between quotes
    
    #option parsing starts with '-' unless it's -off
    if query_string =~ /^\s*-(?!off)/
      query_string.gsub!(option_regex) do
        name, value = $1, $3
        value = $1 if value[/^'(.*)'$/]
        options[name] = value
        ''
      end
    end
    options
  end
  
  def url_encode_string(string, manual_url_encode=nil)
    is_url_encoded = !manual_url_encode.nil? ? manual_url_encode : url_encode?
    is_url_encoded ? CGI.escape(string) : string
  end
  
  # def url_for(query_string, manual_url_encode=nil)
  #   is_url_encoded = !manual_url_encode.nil? ? manual_url_encode : url_encode?
  #   if is_url_encoded
  #     self.url.gsub(DEFAULT_PARAM, CGI.escape(query_string))
  #   else
  #     self.url.gsub(DEFAULT_PARAM,query_string)
  #   end
  # end
  
  #domain value should be the same for command + its usercommand
  #pushing to have no dependence on command when rendering favicons
  def domain
    @domain ||= get_domain
  end
  
  def get_domain
    # Found the regex at http://yubnub.org/kernel/man?args=extractdomainname
    u = url
    if bookmarklet?
      return nil if url.split("http").size == 1
      u = "http" + url.split("http").last
    end
    u=~(/^(?:\w+:\/\/)?([^\/?]+)(?:\/|\?|$)/) ? $1 : nil
  end
  
  def favicon_url
    return "/images/icons/blank_bordered.png" if domain.nil?
    "http://#{domain}/favicon.ico"
  end
  
end