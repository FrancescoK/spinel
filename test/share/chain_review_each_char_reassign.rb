# Under --share-strings (#6765), a chain of calls answering their receiver that
# a boxed || or && takes (chain_review: b03_each_char_reassign) answers what CRuby 4.0 does.
# A nil a bang answered stays nil through tap and itself, and a to_s makes
# "" of it; a block that assigns the variable the chain is over leaves the
# chain on the String it started from.
# each_char with a block that reassigns the slot, then a bang
class App
  def initialize(s) = (@s = s)
  def m(v) = @s.each_char { |c| @s = +"qq" if c == "a" }.upcase! || v
  def s = @s
end
a = App.new(+"abc")
p a.m(1), a.s
