# CRuby reopens its own Encoding here and adds `hi` to it.
# spinel: reject-builtin-class: reopening the builtin class Encoding is not supported
class Encoding
  def hi = "mine"
end

puts "a".encoding
puts "a".encoding.hi
