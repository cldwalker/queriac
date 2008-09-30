#from http://rel.me/2007/02/21/fragment-cache-store-with-ttl/
#adds a ttl to fragment caching
class CacheMemstore

  attr_reader :ttl, :auto_expire
    
  def initialize(options = {})
    @ttl = options[:ttl] || 10.minutes
    @cache = {}
  end
    
  def expire(pattern)
    @cache.each { |key, val| delete key if key =~ pattern }
  end
  
  def read(key, options)
    delete(key, options) and return if is_expired?(key)
    return @cache[key][:content] if @cache.has_key? key
  end
  
  def write(key, content, options)
    @cache[key] = { :content => content, :created_on => Time.now }
  end
  
  def delete_matched(pattern, options)
    expire pattern
  end
  
  def delete(key, options)
    @cache.delete key
  end
  
  def is_expired?(key)
    if @cache.has_key? key
      created_on = @cache[key][:created_on]
      return Time.now > (created_on + @ttl)
    end
  end
  
end