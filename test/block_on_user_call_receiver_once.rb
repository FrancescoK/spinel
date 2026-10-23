# A block written on a call whose receiver is a call answering an object of
# a user class (`E.new.on_click { }`) is emitted into one proc function. The
# receiver was counted as an operand that may convert, so the call went
# through the operand-order trial, which converted nothing and was taken
# back after the block had been emitted: every such block left a second,
# dead proc function behind. infer-test counts the proc functions.
class E
  def initialize; @h = nil; end
  def on_click(&b); @h = b; self; end
  def fire(v) = @h.call(v)
end

def make = E.new

puts(E.new.on_click { |x| x + 1 }.fire(41))
puts(make.on_click { |x| x * 2 }.fire(21))
