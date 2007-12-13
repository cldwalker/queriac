module StringExtensions

  # remove middle from strings exceeding max length.
  def ellipsize(options={})
     max = options[:max] || 40
     delimiter = options[:delimiter] || "..."
     return self if self.size <= max
     offset = max/2
     self[0,offset] + delimiter + self[-offset,offset]
  end
  
  def parameterize
    PARAM_START + self + PARAM_END
  end
  
end