class TagsController < ApplicationController
  before_filter :allow_breadcrumbs, :only=>:index
  def index
    @top_uc_tags = Tag.tag_names_to_count
    @ctags = Tag.tag_names_to_count(:conditions=>'taggable_type="Command"')
    featured_tags = %w{google delicious dictionary mp3player}
    @featured_tag_groups = featured_tags.map {|e| [e, Command.public.find_tagged_with(e, :match_all => true)]}
  end
end