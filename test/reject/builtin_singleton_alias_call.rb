# A captured builtin singleton alias has no compiled user body to call.
# spinel: reject-builtin-class: File.basename: calling an alias of a builtin singleton method is not supported
class File
  class << self
    alias basename_copy basename
  end
end
p File.basename_copy("dir/name")
