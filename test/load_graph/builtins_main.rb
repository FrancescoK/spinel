# The libraries CRuby has at boot are loaded first: the program's own
# methods and reopenings beside them answer as in CRuby.
class Integer
  def digits
    [:mine]
  end
end
def tally = :own_tally
p 1234.digits
p tally
p [3, 1, 2].each_slice(2).to_a
p (1..10).each_cons(3).first
p 12.gcd(8)
p %w[a b a].tally
