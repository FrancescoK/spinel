# An optional default before a post argument remains a possible receiver.
class A; end
class B; end
def probe(a, b = A.new, c)
 b.instance_variable_set(:@z, 7)
 p b.instance_variable_get(:@z)
end
probe(1, B.new)
probe(1, B.new, 2)
