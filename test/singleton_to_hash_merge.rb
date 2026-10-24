# A singleton #to_hash on one instance, merged where its layout differs
# from the receiver's (#3261-style widen, not a refusal).
class Foo; end
k = Foo.new
def k.to_hash
  {a: 1}
end
p({}.merge(k))
p({"x" => 1}.merge(k))

class Bar
  def to_hash
    {a: 1}
  end
end
p({}.merge(Bar.new))

j = Foo.new
def j.to_hash
  {a: 1}
end
p({a: 2}.merge(j))

m = Foo.new
def m.to_hash
  {a: 1, b: 2}
end
p({a: 0, b: 0, c: 3}.merge(m) { |key, old, new| old + new })
pr = ->(key, old, new) { old + new }
p({a: 0, b: 0, c: 3}.merge(m, &pr))
p({str: 1, sym: 0}.merge(Bar.new) { |key, old, new| old + new })

$calls = []
def get_h
  $calls << :recv
  {a: 1}
end
n = Object.new
def n.to_hash
  $calls << :to_hash
  {a: 2}
end
get_h.merge(n) { |key, old, new| old + new }
p $calls
