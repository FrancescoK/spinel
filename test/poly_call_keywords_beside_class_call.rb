# `h.call(1, a: 2)` on a value that may hold a Proc, where a user `call`
# takes the keywords as a positional Hash and some class defines
# `self.call`: the dispatch's callable arm needs a Hash rebuilt from the
# split keywords, and declared it right after the class-value pre-arm,
# which ends in `else`, so the C did not build (#8646). The Hash is declared
# ahead of every pre-arm now. The instance arm gets the positional Hash, the
# Proc gets keywords, a class whose `self.call` does not take them raises
# ArgumentError, and a double splat does the same.
class Widget
  def self.call(x) = x
end

class Gadget
  def call(e, opts = {}) = opts[:a]
end

def run(h) = h.call(1, a: 2)
def run_splat(h) = (kw = { a: 2 }; h.call(1, **kw))

p run(Gadget.new)
p run(->(e, a:) { a + e })
begin
  run(Widget)
rescue ArgumentError => e
  puts e.message
end
p run_splat(Gadget.new)
p run_splat(->(e, a:) { a + e })
begin
  run_splat(Widget)
rescue ArgumentError => e
  puts e.message
end
