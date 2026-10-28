# concat converts its operands in order, after the frozen test: an earlier
# operand's #to_ary that grows a later typed operand is seen, as in CRuby,
# in the statement and the value forms and on a general Array receiver; a
# receiver only the call holds stays alive across the #to_ary.
$b = [5, 6]
class T
  def to_ary
    $b << 7
    GC.start
    [1]
  end
end
x = [T.new, 1].first
r = [0, "s"]
r.concat(x, $b)
p r
r2 = [0, "s"]
p r2.concat(x, $b)
c = [9]
c.concat(x, $b)
p c
def fresh = [0, "q"]
p fresh.concat(x, [2.5], ["z"])
def ifresh = [3]
p ifresh.concat(x, $b)
z = [1].freeze
begin
  z.concat(T.new, 3)
rescue => e
  p e.class
end
p $b
