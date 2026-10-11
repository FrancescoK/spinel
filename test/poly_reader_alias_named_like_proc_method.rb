class Sig
  attr_reader :backing_arity, :backing_year
  alias_method :arity, :backing_arity
  alias year backing_year

  def initialize(arity, year)
    @backing_arity = arity
    @backing_year = year
  end
end

def arity_of(m) = m.arity
def year_of(m) = m.year

p arity_of(proc { |a| a })
p arity_of(Sig.new("two", 1))
p arity_of(Sig.new(3, 1))
p year_of(Time.at(0).utc)
p year_of(Sig.new(0, "y"))
