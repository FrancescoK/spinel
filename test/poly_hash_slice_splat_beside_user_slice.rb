# A receiver that is really a Hash or an Array keeps its builtin slice when
# the keys come as a splat and a user class also owns slice (#7051).
ATTRS = %i[ title url ]

class NodeSet
  def initialize(a) = @a = a
  def slice(start, len = nil) = NodeSet.new(@a[start, len || 1])
  def values_at(*ix) = ix.map { |i| @a[i] }
  def dig(*path) = path.size
  def items = @a
end

def pick(k)
  case k
  when 0 then NodeSet.new([10, 20, 30])
  when 1 then { title: "T", url: "U", other: "O" }
  else [1, 2, 3, 4]
  end
end

h = pick(1)
p h.slice(*ATTRS)
p h.slice(:other, *ATTRS)
p h.slice(*[])
p h.slice(*ATTRS, *[:missing])

# the keys from a local, inside a method
def extract(v, keys) = v.slice(*keys)
p extract(pick(1), [:url])
p extract(pick(2), [1, 2])
p extract(pick(2), [2])

# the splat runs once
calls = 0
p h.slice(*(calls += 1; ATTRS))
p calls

# a user receiver still takes its own slice
p pick(0).slice(*[1, 2]).items

# other builtins beside a user method of the same name
p pick(1).values_at(*ATTRS)
p pick(2).values_at(*[0, 3])
p pick(0).values_at(*[0, 2])
p({ a: { b: 1 } }.then { |x| [x, pick(0)].first }.dig(*[:a, :b]))
