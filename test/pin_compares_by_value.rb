# `in ^pin` compares the subject with the pinned value by ==, as CRuby does:
# an equal Array, Hash or Bignum matches, not only the same object.
ia = [1, 2]
o = [1, 2]
h = { a: 1 }
oh = { a: 1 }
p(case ia; in ^o then :pin; else :no; end)
p(case h; in ^oh then :hpin; else :no; end)
p(case ia; in ^([1, 2]) then :expr_pin; else :no; end)
p(case ia; in ^([2, 1]) then :expr_pin; else :no; end)
case ia
in ^o then p :s_pin
else p :s_no
end
b = 2**70
c = 2**70
p(case b; in ^c then :bpin; else :no; end)
p(case b; in ^(2**71) then :bpin; else :no; end)
p(case [ia]; in [^o] then :nested; else :no; end)
p(case ["x", "y"]; in ^(%w[x y]) then :strs; else :no; end)
# a literal value pattern on a Bignum subject, and the one-line forms
g = 2**70
g = 5 if ARGV.size > 3
p(case g; in 1180591620717411303424 then :lit; else :no; end)
r = (ia in ^o)
p r
# a pinned value from a call whose == allocates
class E
  attr_reader :n
  def initialize(n) = @n = n
  def ==(o)
    3.times { E.new(0) }
    o.is_a?(E) && o.n == @n
  end
end
def mk(i) = [E.new(i), E.new(i + 1)]
miss = []
20.times do |i|
  es = [E.new(i), E.new(i + 1)]
  miss << i unless (case es; in ^(mk(i)) then true; else false; end)
end
p miss
