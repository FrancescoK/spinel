# Under --share-strings (#6765), a chain of calls answering their receiver that
# a boxed || or && takes (chain_review: h01_nil_bang_tap) answers what CRuby 4.0 does.
# A nil a bang answered stays nil through tap and itself, and a to_s makes
# "" of it; a block that assigns the variable the chain is over leaves the
# chain on the String it started from.
# a bang answering nil, then tap: nil.tap answers nil
class App
  def initialize(s) = (@s = s)
  def m(v) = @s.upcase!.tap { } || v
  def n(v) = @s.upcase!.tap { |z| p z }.itself || v
end
p App.new(+"ABC").m(1)
p App.new(+"ABC").n(2)
b = +"abc"
x = App.new(b).n(2)
p [x, x.equal?(b)]
