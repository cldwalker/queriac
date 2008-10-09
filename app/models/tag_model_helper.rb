module TagModelHelper
  
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval %[
      has_many :user_commands, :through=>:taggings, :source=>:taggable, :source_type=>"UserCommand"
      has_many :commands, :through=>:taggings, :source=>:taggable, :source_type=>"Command"
    ]
  end
  
  def before_validation
    self.name.downcase! if self.name
  end
  
  module ClassMethods
    def tags_by_type(tagging_type='UserCommand')
      Tagging.find_all_by_taggable_type(tagging_type).map {|e| e.tag.name}.uniq
    end
    
    #TODO: limit to only public, include and count in :select conflict when using joins
    def tags_by_count(options={})
      Tagging.find(:all, {:conditions=>"taggable_type='UserCommand'",:limit=>20,:group=>"tag_id", :select=>"id,tag_id, count(*) as count", :include=>:tag, :order=>'count DESC'}.merge(options))
    end
    
    def tag_names_to_count(options={})
      hash = {}
      tags_by_count(options).each do |t|
        hash[t.tag.name] = t.count.to_i
      end
      hash
    end
    
    def tag_ids_by_count
      hash = {}
      counts = Tagging.find(:all, :group=>"tag_id", :select=>"tag_id, count(*) as count")
      counts.each {|e| hash[e.tag_id] = e.count.to_i}
      hash
    end
    
    def unused_tag_ids
      Tag.find(:all, :select=>'id').map(&:id) - Tagging.find(:all, :select=>"distinct tag_id").map(&:tag_id)
    end
    
    #console helpers below
    def find_similar_words
      require 'levenshtein'
      tags = Tag.find(:all).map(&:name)
      h = {}
      results = []
      tags.each {|e| l = e[0,1]; h[l] ||= []; h[l] << e }
      h.each do |k,v|
        if v.size > 1
          puts "Starting tags starting with '#{k}'"
          for a in v
            for b in v
              if a!=b
                puts "Checking #{a} with #{b}"
                distance = Levenshtein.distance(a, b)
                if (distance < 3)
                  puts "Found match: #{a}-#{b}: #{distance}"
                  results << [a,b]
                end
              end
            end
          end
        else
          puts "Skipping tags starting with '#{k}'"
        end
      end
      results
    end
    
    def find_plural_pairs
      tags = Tag.find(:all).map(&:name)
      results = []
      tags.each {|e| 
        plural = e.pluralize
        if plural != e && tags.delete(plural)
          results << [e,plural]
        end
      }
      results
    end
  end
end