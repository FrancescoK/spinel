# CRuby reopens its own Encoding here and adds `hi` to it.
class Encoding
  def hi = "mine"
end

puts "a".encoding
puts "a".encoding.hi
