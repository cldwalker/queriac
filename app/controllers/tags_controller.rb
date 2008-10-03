class TagsController < ApplicationController
  def index
    @top_uc_tags = Tag.tag_names_to_count
    featured_tags = %w{google delicious dictionary mp3player}
    @featured_tag_groups = featured_tags.map {|e| [e, Command.public.find_tagged_with(e, :match_all => true)]}
    @ctags = Tag.tag_names_to_count(:conditions=>'taggable_type="Command"')
  end
end