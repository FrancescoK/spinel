# An --rbs `Integer?` / `Float?` / `bool?` / `Symbol?` ivar seed must keep nil
# distinguishable from the type's zero. The seed pins the slot to the unboxed
# kind, so assigning a poly RHS (here a nil arriving through a setter) unboxes
# it -- and `.v.i` on a boxed nil reads the payload under the tag, 0. int and
# float have a reserved sentinel to land on; bool and symbol have none, so
# their seeds pin to the boxed union instead. #3412.
# spinel: rbs-seed-check
class NilRow
  def initialize
    @n = nil
    @r = nil
    @s = nil
    @f = nil
    @y = nil
  end
  def n; @n; end
  def n=(v); @n = v; end
  def r; @r; end
  def r=(v); @r = v; end
  def s; @s; end
  def s=(v); @s = v; end
  def f; @f; end
  def f=(v); @f = v; end
  def y; @y; end
  def y=(v); @y = v; end
end

def show(row)
  puts [row.n.inspect, row.r.inspect, row.s.inspect,
        row.f.inspect, row.y.inspect].join(" ")
end

# a fresh row: every seeded slot starts nil
row = NilRow.new
show(row)

# real values round-trip through the same slots
row.n = 7
row.r = 1.5
row.s = "x"
row.f = false
row.y = :a
show(row)

# and the zero of each type stays distinct from nil
row.n = 0
row.r = 0.0
row.s = ""
show(row)

# assigning nil back through the setter must restore nil, not the zero
row.n = nil
row.r = nil
row.s = nil
row.f = nil
row.y = nil
show(row)
puts row.n.nil?
puts row.r.nil?
puts row.f.nil?
puts row.y.nil?

# the shape that surfaced it: grouping rows by a nilable Integer column must
# file the nil-keyed ones under nil, not under 0
rows = [1, nil, 0, nil].map { |v| r = NilRow.new; r.n = v; r }
groups = rows.group_by { |x| x.n }
puts groups[nil].length
puts groups[0].length
