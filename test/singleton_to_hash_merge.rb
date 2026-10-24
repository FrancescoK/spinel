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
