require 'ostruct'

#Option objects mainly used in helpers and in url_for()
class Option < OpenStruct
  OPTION_TYPES = ['normal', 'boolean', 'enumerated']
  VALID_FIELDS = [:name, :option_type, :description, :alias, :true_value, :false_value, :default, :values, :value_aliases, :value_prefix, :param]
  GLOBAL_OPTIONS = ['off', 'help', 'h', 'print']
  
  def self.sanitize_input(array_of_hashes)
    array_of_hashes.map {|e| 
      #ensure keys are symbols
      e = e.symbolize_keys
      #ensures url_options input only has allowed fields
      e.slice!(*VALID_FIELDS)
      optional_columns = [:value_prefix, :value_aliases, :default, :description, :alias, :param]
      optional_columns.each {|c| e.delete(c) if e[c].blank? }
      e[:option_type] ||= 'normal'
      e
    }
  end
  
  def self.find_and_create_by_name(options_array, name)
    (option = options_array.find {|e| e[:name] == name }) ? Option.new(option) : nil
  end
  
  def self.find_label_for_hpricot_element(hpricot_form, hpricot_element)
    if hpricot_element[:id] && (label_tag = hpricot_form.at("label[@for=#{hpricot_element[:id]}]"))
      label_tag.inner_text
    else
      nil
    end
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
          hash[:label] = label
        end
        hash[:values_array] << e[:value]
        hash[:default] = e[:value] if e.attributes.has_key?('checked')
      #boolean
      when 'checkbox'
        hash = {:input_type=>'checkbox', :option_type=>'boolean'}
        if (label = find_label_for_hpricot_element(form, e))
          hash[:label] = label
        end
        hash[:true_value] = !e[:value].blank? ? e[:value] : 'on'
        hash[:checked] = e.attributes.has_key?('checked')
      else
        hash = {:input_type=>e[:type], :option_type=>'normal'}
        hash[:value] = e[:value] unless (e[:type] == 'text' or e[:type].nil?)
        if (label = find_label_for_hpricot_element(form, e))
          hash[:label] = label
        end
      end
      options[e[:name]] = hash
    end
    
    #enumerated with possible multi
    (form/"select").each do |s|
      hash = {:input_type=>'select', :values_hash=>{}, :option_type=>'enumerated'}
      (s/"option").each do |opt|
        hash[:values_hash][opt[:value]] = opt.inner_html
        hash[:default] = opt[:value] if opt.attributes.has_key?('selected')
      end
      if (label = find_label_for_hpricot_element(form, s))
        hash[:label] = label
      end
      options[s[:name]] = hash
    end
    
    (form/"textarea").each do |e|
      options[e[:name]] = {:input_type=>'textarea', :option_type=>'normal'}
      if (label = find_label_for_hpricot_element(form, e))
        options[e[:name]][:label] = label
      end
    end
    options.each {|k,v| v[:param] = k}
    options.values.map {|e| Option.new(e) }
  end
  
  #TODO: ensure value_aliases only have valid values
  #first array defines allowed options
  #second array overrides nonessential fields for a common option
  def self.merge_option_arrays(first, second)
    merged_option_array = first.dup
    merged_option_array.each {|e|
      exception_keys = [:option_type, :values, :param, :name]
      if (option = second.find {|f| f[:name] == e[:name]})
        #ensure default is an allowed value
        if e[:values] && !option[:default].nil? && ! Option.new(:values=>e[:values]).values_list.include?(option[:default])
          exception_keys << :default
        end
        e.merge!(option.except(*exception_keys))
      end
    }
    merged_option_array
  end
  
  # Console helper: Lists all currently used option names and aliases
  def self.all_options
    Command.with_options.map {|e| e.user_commands.map {|f| f.url_options.map {|o| [o[:name], o[:alias]] } }}.flatten.compact.uniq.sort
  end
  
  #should return array
  def values_list(values_to_split=self.values)
    values_to_split.gsub(/\(.*?\)/, '').split(/\s*,\s*/)
  end
  
  def prefix_value(value)
    self.value_prefix.blank? ? value : self.value_prefix + value
  end
  
  def alias_value(value)
    return value if self.value_aliases.blank?
    values_array = self.value_aliases.split(/\s*,\s*/).map {|e| e.split("=", 2) }.flatten
    value_aliases_hash = Hash[*values_array]
    value_aliases_hash[value] || value
  end
  
  # def argument?(name_value=self.name)
  #   name =~ /^\d$/ ? true :false
  # end
  # 
  # def has_metadata?
  #   (VALID_FIELDS - [:name, :option_type]).any? {|e| ! send(e).blank? }
  # end  
end