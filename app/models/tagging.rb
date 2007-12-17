# == Schema Information
# Schema version: 10
#
# Table name: taggings
#
#  id            :integer(11)     not null, primary key
#  tag_id        :integer(11)     default(0), not null
#  taggable_id   :integer(11)     default(0), not null
#  taggable_type :string(255)     default(""), not null
#

class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true

  def before_destroy
    # disallow orphaned tags
    tag.destroy_without_callbacks if tag.taggings.count < 2  
  end
end
