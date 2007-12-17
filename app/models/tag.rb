# == Schema Information
# Schema version: 10
#
# Table name: tags
#
#  id   :integer(11)     not null, primary key
#  name :string(255)     default(""), not null
#

class Tag < ActiveRecord::Base  
  has_many_polymorphs :taggables, 
    :from => [:commands], 
    :through => :taggings,
    :dependent => :destroy
end

class ActiveRecord::Base
  def tag_with tags
    tags.downcase.split(" ").each do |tag|
      Tag.find_or_create_by_name(tag).taggables << self
    end
  end
  alias :tags= :tag_with
  
  def tag_list
    tags.map(&:name).join(' ')
  end
  
  def tag_delete tag_string
    split = tag_string.downcase.split(" ")
    tags.delete tags.select{|t| split.include? t.name}
  end
  
  def update_tags new_tags
    tag_delete tag_list
    tag_with new_tags
  end
  
end
