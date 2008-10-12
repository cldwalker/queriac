##
# Copy this file to vendor/plugins/acts_as_cached/extensions.rb if you 
# wish to extend acts_as_cached with your own instance or class methods.
#
# You can, of course, do this directly in your cached classes,
# but keeping your custom methods here allows you to define
# methods for all cached objects DRYly.
module ActsAsCached
  module Extensions
    module ClassMethods
      ##
      # All acts_as_cached classes will be extended with 
      # this method.
      #
      # >> Story.multi_get_cache(13, 353, 1231, 505)
      # => [<Story:13>, <Story:353>, ...]
      def multi_get_cache(*ids)
        ids.flatten.map { |id| get_cache(id) }
      end
    end

    module InstanceMethods
      ##
      # All instances of a acts_as_cached class will be 
      # extended with this method.
      #
      # => story = Story.get_cache(1)
      # => <Story:1>
      # >> story.reset_included_caches
      # => true
      def reset_included_caches
        return false unless associations = cache_config[:include]
        associations.each do |association| 
          Array(send(association)).each { |item| item.reset_cache }
        end
        true
      end
      
      # used in the same way as cached() and caches()
      def expire_cached(method, options={})
        key = "#{id}:#{method}"
        if options.keys.include?(:with)
          with = options.delete(:with)
          self.class.expire_cache("#{key}:#{with}")
        elsif withs = options.delete(:withs)
          self.class.expire_cache("#{key}:#{withs}")
        else
          self.class.expire_cache(key)
        end
      end
    end
  end
end
