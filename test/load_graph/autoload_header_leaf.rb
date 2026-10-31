# A header or a mixin receiver whose own constant an autoload registers, in
# a scope the program defines: the header's or the receiver's read runs the
# file first, and the class it opens is the file's.
module HeaderOuter
  autoload :Box, File.join(__dir__, "autoload_header_leaf_lib")
end
autoload :HeaderTop, File.join(__dir__, "autoload_header_leaf_top_lib")
module HeaderMix
  def hi = "hi from HeaderMix"
end
module HeaderCm
  def chi = "chi"
end
puts "main"
class HeaderOuter::Box
  def more = "more"
end
HeaderOuter::Box.include(HeaderMix)
p HeaderOuter::Box.new.own, HeaderOuter::Box.new.more, HeaderOuter::Box.new.hi
HeaderTop.include(HeaderMix)
HeaderTop.extend(HeaderCm)
p HeaderTop.new.hi, HeaderTop.new.own, HeaderTop.cm, HeaderTop.chi
