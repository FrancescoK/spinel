# Under --share-strings (#6765), a chain of calls answering their receiver that
# a boxed || or && takes (chain_review: a11_min_nil_to_s) answers what CRuby 4.0 does.
# A nil a bang answered stays nil through tap and itself, and a to_s makes
# "" of it; a block that assigns the variable the chain is over leaves the
# chain on the String it started from.
# minimal: a bang answering nil, then to_s, as a || operand of a method tail
class App
  def initialize(s) = (@s = s)
  def m(v) = @s.upcase!.to_s || v
end
p App.new(+"ABC").m(1)
