# FormParser parses forms and converts them to arrays of option objects.
# This is class is tightly coupled to Option.
class FormParser
  #js example at http://ostermiller.org/bookmarklets/form.html- Extract Forms
  def self.scrape_form(url, options={})
    text = ''
    if !url.blank?
      url.strip!
      begin
        text = open(url)
      rescue
        logger.error "Scrape failed with error: #{$!}\n:url '#{url}' and options: #{options.inspect}"
        return nil
      end
    elsif !options[:text].blank?
      text = options[:text]
    end
    if (form = (Hpricot(text)/"form")[0])
      form_text = form.to_html 
      options = self.scrape_options_from_form(form_text)
    end
    action_url = URI.parse(url).merge(form['action']).to_s rescue nil
    return action_url, options, form
  end
  
  def self.scrape_options_from_form(form_text)
    form = Hpricot(form_text).at("form")
    options = {}
    (form /"input").each do |e|
      case e[:type]
      #enumerated
      when 'radio'
        hash = options.has_key?(e[:name]) ? options[e[:name]] : {:option_type=>'enumerated', :input_type=>'radio',:values_array=>[]}
        if (label = find_label_for_hpricot_element(form, e))
          hash[:description] = label
        end
        hash[:values_array] << e[:value]
        hash[:default] = e[:value] if e.attributes.has_key?('checked')
      #boolean
      when 'checkbox'
        hash = {:input_type=>'checkbox', :option_type=>'boolean'}
        if (label = find_label_for_hpricot_element(form, e))
          hash[:description] = label
        end
        hash[:true_value] = !e[:value].blank? ? e[:value] : 'on'
        hash[:checked] = e.attributes.has_key?('checked')
      else
        hash = {:input_type=>e[:type], :option_type=>'normal'}
        hash[:value] = e[:value] unless (e[:type] == 'text' or e[:type].nil?)
        if (label = find_label_for_hpricot_element(form, e))
          hash[:description] = label
        end
      end
      options[e[:name]] = hash
    end
    
    #enumerated with possible multi
    (form/"select").each do |s|
      hash = {:input_type=>'select', :values_hash=>{}, :option_type=>'enumerated'}
      (s/"option").each do |opt|
        hash[:values_hash][opt[:value]] = opt.inner_text.gsub("\n", '')
        hash[:default] = opt[:value] if opt.attributes.has_key?('selected')
      end
      if (label = find_label_for_hpricot_element(form, s))
        hash[:description] = label
      end
      options[s[:name]] = hash
    end
    
    (form/"textarea").each do |e|
      options[e[:name]] = {:input_type=>'textarea', :option_type=>'normal'}
      if (label = find_label_for_hpricot_element(form, e))
        options[e[:name]][:description] = label
      end
    end
    options.each {|k,v| v[:param] = k; v[:name] = k}
    sanitize_scraped_data(options.values).map {|e| Option.new(e) }
  end
  
  def self.logger; ActiveRecord::Base.logger; end
  
  def self.sanitize_scraped_data(array_of_hashes)
    invalid_value_characters = "[(),]"
    invalid_values_regex = /[(),]/
    array_of_hashes.each do |e|
      if e[:values_hash]
        e[:values_hash].delete(nil) #for sites like web.archive.org (arch command)
        e[:values_hash].delete("") #happens enough for defaults values
        #report invalid values
        invalid_values = e[:values_hash].select {|k,v| k =~ invalid_values_regex || v =~ invalid_values_regex}
        invalid_hash = Hash[*invalid_values.flatten]
        if !invalid_values.empty?
          e[:note] = "The following value(s) have prohibited characters: #{invalid_hash.map {|k,v| k + ': ' + v}.join('; ')}"
        end
        
        #create valid values + values_hash
        valid_keys = e[:values_hash].keys.select {|k| k !~ invalid_values_regex }
        e[:values] = Option.values_string(valid_keys)
        valid_hash = e[:values_hash].slice(*valid_keys)
        valid_hash.each {|k,v| valid_hash[k] = '' if v =~ invalid_values_regex}
        e[:values_hash] = valid_hash
      elsif e[:values_array]
        valid_values, invalid_values = e[:values_array].partition {|f| f !~ /[(),]/}
        if !invalid_values.empty?
          e[:note] = "The following value(s) have prohibited characters: #{invalid_values.join('; ')}"
        end
        e[:values] = Option.values_string(valid_values)
      end
    end
    #handle blank names
    array_of_hashes = array_of_hashes.select {|e| 
      if e[:name].blank? && e[:input_type] != 'submit'
        logger.info "Parsed option with blank name: #{e.inspect}"
      end
      !e[:name].blank?
    }
    Option.sanitize_input(array_of_hashes)
  end
  
  def self.create_command_url_and_options_from_scrape(action_url, url_options, options={})
    #the messages are to let admin know if commands are exceeding the current limits often and adjust them as needed
    message = ''
    #clean up options
    url_options.reject! {|e| e.name == 'submit'}
    long_options = []
    url_options.each {|e|
      if e.values_hash
        if options[:is_admin] || e.annotated_values.to_s.length <= Option::FIELD_LENGTH_MAX
          if e.annotated_values.to_s.length > Option::FIELD_LENGTH_MAX
            long_options << e.name
          end
          e.values = e.annotated_values
        end
      end
    }
    message += "The following options have annotated values longer than the #{Option::FIELD_LENGTH_MAX} character limit: #{long_options.join(', ')}<br/>" unless long_options.empty?
    if url_options.size > Option::MAX_OPTIONS
      if options[:is_admin]
        message += "This command has #{url_options.size} options (the limit for everyone else is #{Option::MAX_OPTIONS})"
      else
        url_options = url_options.slice(0, Option::MAX_OPTIONS)
      end
    end
    
    #generate command url
    hardcoded_options, dynamic_options = url_options.partition {|e| e.option_type == 'normal' && !e.value.blank? }
    url_options_array = hardcoded_options.map {|e| "#{e.name}=#{e.value}"} + dynamic_options.map {|e| "[:#{e.name}]"}
    command_url = action_url + "?" + url_options_array.join("&")
    return command_url, url_options, message    
  end
  
  def self.find_label_for_hpricot_element(hpricot_form, hpricot_element)
    if hpricot_element[:id] && (label_tag = hpricot_form.at("label[@for=#{hpricot_element[:id]}]")) && label_tag.inner_text
      CGI::unescapeHTML(label_tag.inner_text)
    else
      nil
    end
  end
  
end