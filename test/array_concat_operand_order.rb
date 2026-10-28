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
# a typed or poly operand before a boxed one is copied at its turn: a
# later #to_ary that changes it does not change what is appended
$s = [5, 6, 7, 8]
class U
  def to_ary
    $s.clear
    $s << 42
    [1]
  end
end
y = [U.new, 1].first
i = [1, 2]
i.concat($s, y)
p i
$s = [5, 6, 7, 8]
p [0, "s"].concat($s, y)
$q = [1, "a"]
class V
  def to_ary
    $q << 9
    [1]
  end
end
w = [V.new, 1].first
p [0, "s"].concat($q, w)
$r = [0, "s"]
$r.concat($r, w)
p $r
# a typed receiver a builtin call just built: the operands convert after
# the frozen test, each copied at its turn
$t = [5, 6, 7, 8]
$log = []
class Z
  def to_ary
    $log << :to_ary
    $t.clear
    GC.start
    [1]
  end
end
zz = [Z.new, 1].first
def ofresh = [3]
p ofresh.concat($t, zz)
def ofrozen = [3].freeze
begin
  ofrozen.concat(zz, $t)
rescue => e
  p e.class
end
p $log
