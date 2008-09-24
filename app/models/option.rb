require 'ostruct'

#Option objects mainly used in helpers and in url_for()
class Option < OpenStruct
  OPTION_TYPES = ['normal', 'boolean', 'enumerated']
  VALID_FIELDS = [:name, :option_type, :description, :alias, :true_value, :false_value, :default, :values, :value_aliases,
    :value_prefix, :param, :private]
  #these fields are hidden + not copied when private field is set
  #should be in sync with option_metadata() helper
  PRIVATE_FIELDS = [:default, :value_aliases]
  #maps names to aliases
  GLOBAL_OPTION_ALIASES = {'help'=>'h', 'test'=>'T', 'url_encode'=>'ue'} 
  GLOBAL_OPTIONS = ['off'] + GLOBAL_OPTION_ALIASES.to_a.flatten
  GLOBAL_BOOLEAN_OPTIONS = GLOBAL_OPTION_ALIASES.slice('help', 'test').to_a.flatten
  FIELD_LENGTH_MAX = 4000 #txt command provider values comes close to this
  MAX_OPTIONS = 25
  VALUES_SPLITTER = /\s*,\s*/
  
  def self.sanitize_input(array_of_hashes, options = {})
    array_of_hashes.map {|e| 
      #ensure keys are symbols
      e = e.symbolize_keys
      valid_fields = VALID_FIELDS
      valid_fields += options[:additional_fields] unless options[:additional_fields].blank?
      #ensures url_options input only has allowed fields
      e.slice!(*valid_fields)
      optional_columns = [:value_prefix, :value_aliases, :default, :description, :alias, :param]
      optional_columns.each {|c| e.delete(c) if e[c].blank? }
      e[:option_type] ||= 'normal'
      e
    }
  end
  
  def self.sanitize_copied_options(array_of_hashes)
    array_of_hashes.map {|e| 
      e.except!(*PRIVATE_FIELDS) if Option.private_option?(e[:private])
      e.delete(:private)
      e
    }
  end
  
  #should be in sync with global options constants except for ! option
  def self.global_options
    global_opt = [{:name=>'help', :option_type=>'boolean', :alias=>'h', :description=>'Displays help page for user command.'}, 
      {:name=>'test', :alias=>'T', :description=>'Tests a user command and its arguments by displaying its result.', :option_type=>'boolean'},
      {:name=>'url_encode', :alias=>'ue', :option_type=>'normal', :description=>"Override default url encode. 1 toggles it on and 0 toggles it off."},
      {:name=>'off', :option_type=>'boolean', :description=>"Turns off option parsing for remainder of command"},
      {:name=>"!", :option_type=>'boolean', :description=>"Toggles a command's default save queries state ie a query isn't saved that would normally be saved. This is not a traditional option since it must come before the command."}]
    global_opt.map {|e| Option.new(e) }
  end
  
  #assumes that an option is intended to be a param if after a '?' and isn't preceeded by '=' or ' '
  #doesn't handle edge case like google's advanced search ie a '#' instead of '?'
  def self.detect_and_add_params_to_options(options, url)
    unless Command.url_is_bookmarklet?(url)
      options.each do |opt|
        #note: option format is hardcoded here
        opt.param = opt.name if opt.param.nil? && (url =~ /\?.*\[:#{opt.name}\]/) && (url !~ /[= ]\[:#{opt.name}\]/)
      end
    end
  end
  
  def self.find_and_create_by_name(options_array, name)
    (option = options_array.find {|e| e[:name] == name }) ? Option.new(option) : nil
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
    Command.options.map {|e| e.user_commands.map {|f| f.url_options.map {|o| [o[:name], o[:alias]] } }}.flatten.compact.uniq.sort
  end
  
  #should return array
  def values_list(values_to_split=self.values)
    values_to_split.gsub(/\(.*?\)/, '').split(VALUES_SPLITTER)
  end
  
  #returns array of arrays mapping annotation to value
  def annotated_values_list(values_to_split=self.values)
    values_to_split.split(VALUES_SPLITTER).map {|e|
      k = e.gsub(/\((.*)?\)/, '')
      $1 ? [$1, k] : [e,e]
    }
  end
  
  def sorted_annotated_values_list
    annotated_values_list.sort {|a,b| a[0]<=>b[0]}
  end
  
  def values_string(values_array)
    values_array.join(", ")
  end
  
  def self.values_string(values_array)
    values_array.join(", ")
  end
  
  def annotated_values
    values_hash ? values_string(values_hash.map {|k,v| k + (!v.blank? ? "(#{v})" : '')}) : nil
  end
  
  def sorted_values(values_to_split=self.values)
    values_string(values_to_split.split(VALUES_SPLITTER).sort)
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
  
  def self.private_option?(value); value == '1'; end
  def private?; self.class.private_option?(self.private); end
  def public?; !private?; end
  
  #from ostruct
  def to_hash
    @table
  end
  
  # def argument?(name_value=self.name)
  #   name =~ /^\d$/ ? true :false
  # end
  # 
  # def has_metadata?
  #   (VALID_FIELDS - [:name, :option_type]).any? {|e| ! send(e).blank? }
  # end  
end