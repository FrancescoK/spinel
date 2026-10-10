class Bound
  attr_reader :arity, :call

  def initialize(arity, call)
    @arity = arity
    @call = call
  end
end

def arity_of(m) = m.arity
def call_of(m) = m.call

p arity_of(Bound.new(2, :x))
p arity_of(->(a, b, c) { a })
p arity_of(proc { |*r| r })
p call_of(Bound.new(1, "called"))
p call_of(-> { 7 })

def arity_or_error(m)
  m.arity
rescue NoMethodError => e
  e.message
end

p arity_or_error(Bound.new(0, nil))
p arity_or_error(:sym)
