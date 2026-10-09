# Captured builtin singleton dispatch is refused until it can keep its target.
# spinel: reject-builtin-class: File.basename: alias of a builtin singleton method that is later overridden is not supported
class File
  class << self
    alias original_basename basename
    def basename(path) = "wrapped:#{original_basename(path)}"
  end
end
p File.basename("dir/name")
