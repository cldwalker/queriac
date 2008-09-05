class FormParser
  def self.sanitize_scraped_data(array_of_hashes)
    array_of_hashes.each do |e|
      if e[:values_hash]
        e[:values_hash].delete(nil) #for sites like web.archive.org (arch command)
        valid_values, invalid_values = e[:values_hash].partition {|k,v| k !~ /[(),]/ && v !~ /[(),]/}
        valid_hash = Hash[*valid_values.flatten]
        invalid_hash = Hash[*invalid_values.flatten]
        if !invalid_values.empty?
          e[:note] = "The following value(s) are invalid: #{invalid_hash.map {|k,v| k + ': ' + v}.join('; ')}"
        end
        e[:values] = Option.new.values_string(valid_hash.keys)
        e[:values_hash] = valid_hash
      elsif e[:values_array]
        valid_values, invalid_values = e[:values_array].partition {|f| f !~ /[(),]/}
        if !invalid_values.empty?
          e[:note] = "The following value(s) are invalid: #{invalid_values.join('; ')}"
        end
        e[:values] = Option.new.values_string(valid_values)
      end
    end
    Option.sanitize_input(array_of_hashes)
  end
  
  
  def self.scrape_form(url, options={})
    if !url.blank?
      url.strip!
      text = open(url)
    elsif !options[:text].blank?
      text = options[:text]
    end
    if (@form = (Hpricot(text)/"form")[0])
      form_text = @form.to_html 
      options = self.scrape_options_from_form(form_text)
    end
    action_url = URI.parse(url).merge(@form['action']).to_s rescue nil
    return action_url, options, @form
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
        hash[:values_hash][opt[:value]] = opt.inner_html.gsub("\n", '')
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
    # ActiveRecord::Base.logger.debug options.values.inspect
    sanitize_scraped_data(options.values).map {|e| Option.new(e) }
  end
  
  def self.find_label_for_hpricot_element(hpricot_form, hpricot_element)
    if hpricot_element[:id] && (label_tag = hpricot_form.at("label[@for=#{hpricot_element[:id]}]"))
      label_tag.inner_text
    else
      nil
    end
  end
  
end