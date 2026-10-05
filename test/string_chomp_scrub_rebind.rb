# String cleanup keeps the receiver read before an argument rebinds it.
s = +"ab"
p s.chomp!(s = +"b")
p s
s = +"hello"
p s.scrub!(s = +"x")
p s
s = +"ab"
s.chomp!(s = +"b")
p s
s = +"hello"
s.scrub!(s = +"x")
p s
class CleanupHolder
  def run
    @s = +"ab"
    p @s.chomp!(@s = +"b")
    p @s
    @s = +"hello"
    p @s.scrub!(@s = +"x")
    p @s
  end
end
CleanupHolder.new.run
