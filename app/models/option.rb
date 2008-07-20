require 'ostruct'

#Option objects mainly used in helpers and in url_for()
class Option < OpenStruct
  OPTION_TYPES = ['normal', 'boolean', 'enumerated']
  VALID_FIELDS = [:name, :option_type, :description, :alias, :true_value, :false_value, :default, :values, :value_aliases, :value_prefix]
  
  def self.sanitize_input(array_of_hashes)
    array_of_hashes.map {|e| 
      #ensure keys are symbols
      e = e.symbolize_keys
      #ensures url_options input only has allowed fields
      e.slice!(*VALID_FIELDS)
      e[:option_type] ||= 'normal'
      e
    }
  end
  
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