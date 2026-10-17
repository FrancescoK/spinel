# The `new` arm of a boxed `[]` that may hold a Data class is taken only for
# that class: classes whose constructors take the same arguments sit beside
# it, a boxed `new` reaches each of them, and every `[]` still answers as before.
K = Data.define(:digest)
P = Struct.new(:x, :y)

class C0; def initialize(v) = @v = v; def v = @v; end
class C1; def initialize(v) = @v = v; def v = @v; end
class C2; def initialize(v) = @v = v; def v = @v; end

KS = [C0, C1, C2]
p KS.map { |k| k.new(1).v }
p KS.map { |k| k.new(:s).v }

def get(x) = x[:a]
def pair(x) = x[1, 2]

p get({a: 1})
p get({a: "s"})
p get([K, 0][0])
p get([K, 0][0]).digest
p pair([P, 0][0])
p pair([10, 20, 30, 40])
p pair("abcdef")
box = [C0, 1][0]
p box.new(7).v
