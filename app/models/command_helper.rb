module CommandHelper
  def url_for(query_string, manual_url_encode=nil)
    is_url_encoded = !manual_url_encode.nil? ? manual_url_encode : url_encode?
    if is_url_encoded
      self.url.gsub(DEFAULT_PARAM, CGI.escape(query_string))
    else
      self.url.gsub(DEFAULT_PARAM,query_string)
    end
  end
  
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