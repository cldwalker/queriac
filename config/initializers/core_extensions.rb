class Hash
  def grep(*args)
    valid = self.keys.grep(*args)
    self.reject {|k, v| !valid.include?(k) }
  end
end

class String

  # remove middle from strings exceeding max length.
  def ellipsize(options={})
     max = options[:max] || 40
     delimiter = options[:delimiter] || "..."
     return self if self.size <= max
     offset = max/2
     self[0,offset] + delimiter + self[-offset,offset]
  end
  
end