module TagModelHelper
  
  def self.included(base)
    base.extend(ClassMethods)
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
  end
end