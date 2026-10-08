# The yield/return/dispatch counterparts of #3493. A nilable scalar slot holds
# nil as the reserved sentinel, and boxing it into a poly context has to spell
# that nil -- but "can this slot hold the sentinel?" was answered from the
# syntactic SHAPE of the producing expression, so three shapes went unmarked
# and their nil became a Hash key no literal nil could match (#3505):
#
#   1. `k = yield x`      -- the value is the BLOCK's, decided per call site
#   2. `k = pass(r)`      -- a method whose nilable return no RBS declares
#   3. `k = rows[0].p_`   -- a receiver the fixpoint left poly, so no single
#                            callee resolves and only the dispatch set knows
#
# Each is checked twice: once through a local (the slot's own marking) and once
# boxed straight from the expression (codegen's per-site choice).
# spinel: rbs-seed-run
class YkR
  def initialize(p)
    @p = p
  end

  def p_
    @p
  end
end

def yk_key_of(x)
  yield x
end

def yk_pass(x)
  x.p_
end

# 1. through a block
h1 = {}
k1 = yk_key_of(YkR.new(nil)) { |x| x.p_ }
h1[k1] = "block"
h1[nil] = "literal"
puts "yield  len=#{h1.length} val=#{h1[nil].inspect} cls=#{k1.class} nil?=#{k1.nil?}"

h2 = {}
h2[yk_key_of(YkR.new(nil)) { |x| x.p_ }] = "block"
h2[nil] = "literal"
puts "yield! len=#{h2.length} val=#{h2[nil].inspect}"

# 2. through a method whose nilable return is inferred, not seeded
h3 = {}
k3 = yk_pass(YkR.new(nil))
h3[k3] = "pass"
h3[nil] = "literal"
puts "pass   len=#{h3.length} val=#{h3[nil].inspect} cls=#{k3.class} nil?=#{k3.nil?}"

h4 = {}
h4[yk_pass(YkR.new(nil))] = "pass"
h4[nil] = "literal"
puts "pass!  len=#{h4.length} val=#{h4[nil].inspect}"

# 3. through a receiver that stayed poly
rows = [YkR.new(nil), YkR.new(7), YkR.new(nil)]
rows.each { |x| x.p_ }
h5 = {}
k5 = rows[0].p_
h5[k5] = "poly"
h5[nil] = "literal"
puts "poly   len=#{h5.length} val=#{h5[nil].inspect} cls=#{k5.class} nil?=#{k5.nil?}"

h6 = {}
h6[rows[0].p_] = "poly"
h6[nil] = "literal"
puts "poly!  len=#{h6.length} val=#{h6[nil].inspect}"

# A Float? slot has its own reserved sentinel and the same three shapes.
class YkF
  def initialize(v)
    @v = v
  end

  def val
    @v
  end
end

def yk_fkey_of(x)
  yield x
end

hf = {}
kf = yk_fkey_of(YkF.new(nil)) { |x| x.val }
hf[kf] = "block"
hf[nil] = "literal"
puts "float  len=#{hf.length} val=#{hf[nil].inspect} cls=#{kf.class} nil?=#{kf.nil?}"

# The shape this was found in: group_by a nullable foreign key through a block,
# then reach for the nil bucket to find the roots of the tree.
def yk_group_by(arr)
  out = {}
  arr.each do |x|
    k = yield x
    a = out.fetch(k, nil)
    if a.nil?
      a = []
      out[k] = a
    end
    a << x
  end
  out
end

class YkRow
  def initialize(id, parent)
    @id = id
    @parent = parent
  end

  def id
    @id
  end

  def parent_id
    @parent
  end
end

trows = [YkRow.new(1, nil), YkRow.new(2, 1), YkRow.new(3, nil), YkRow.new(4, 2)]
groups = yk_group_by(trows) { |r| r.parent_id }
puts "groups #{groups.length}"
puts "roots  #{groups[nil].map { |r| r.id }.inspect}"
puts "kids   #{groups[1].map { |r| r.id }.inspect}"

# A real (non-nil) value must still box as itself, not get swept into nil.
hn = {}
hn[yk_key_of(YkR.new(7)) { |x| x.p_ }] = "seven"
hn[nil] = "literal"
puts "mixed  len=#{hn.length} seven=#{hn[7].inspect} nil=#{hn[nil].inspect}"
