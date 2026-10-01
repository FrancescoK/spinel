# A builtin class or module with no class id of its own (Random, Process,
# GC, ObjectSpace, Method, UnboundMethod, and Enumerator::Chain, ::Lazy and
# ::Product by their paths) is a Class value when read as one, as CRuby's
# constant is: it prints, names itself, compares and hashes by name, equals
# what an instance's #class answers, and passes to a method. It was read as
# a constant defined nowhere, a NameError at run time.
ks = [Random, Process, GC, ObjectSpace, Method, UnboundMethod]
p ks
p ks.map(&:name), ks.map(&:to_s)
k = Process
p k == Process, k == GC, k.equal?(Process), Random.name.frozen?
p [Random.new(1).class == Random, Random.new(1).class.name]
def kname(k) = k.name
p kname(GC), kname(Random)
h = { Random => 1, Process => 2 }
p h[Random], h.size
x = Random
p x, x.inspect
p Enumerator::Chain, Enumerator::Lazy, Enumerator::Product
e = Enumerator::Product
p e.name, e == Enumerator::Chain
p [1].chain([2]).class == Enumerator::Chain, [1].lazy.class == Enumerator::Lazy
