class Sig
  attr_reader :parameters, :curry, :arity, :year

  def initialize(parameters, curry, arity, year)
    @parameters = parameters
    @curry = curry
    @arity = arity
    @year = year
  end
end

def parameters_of(m) = m.parameters
def curry_of(m) = m.curry
def arity_of(m) = m.arity
def year_of(m) = m.year

sig = Sig.new(2, "c", "two", "y")
p parameters_of(sig)
p parameters_of(->(a, b = 1) { a })
p curry_of(sig)
p curry_of(->(a, b) { a + b })[1][2]
p arity_of(sig)
p arity_of(Sig.new(0, "", 3, ""))
p arity_of(proc { |a| a })
p year_of(sig)
p year_of(Time.at(0).utc)

[Sig.new(4, 5, 6, 7), Sig.new("p", "c", "a", "y")].each do |s|
  p [parameters_of(s), curry_of(s), arity_of(s), year_of(s)]
end
