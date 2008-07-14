require 'ostruct'

#Option objects mainly used in helpers and in url_for()
class Option < OpenStruct
  OPTION_TYPES = ['normal', 'boolean', 'enumerated']
  VALID_FIELDS = [:name, :option_type, :description, :alias, :true_value, :false_value, :default, :values]
  
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
  
  def has_metadata?
    (VALID_FIELDS - [:name, :option_type]).any? {|e| ! send(e).blank? }
  end  
end