# The method a call reaches through a later redefinition answers to the
# method's own name wherever Ruby shows it: __method__, the count in an
# ArgumentError, a Method or UnboundMethod's name and inspect, the
# reflection lists, respond_to? and send.
def k(a) = "k1 #{__method__} #{a}"
def w(*a) = k(*a)
def v(a, b) = k(a, b)
puts w(1)
def k(a) = "k2 #{__method__} #{a}"
puts w(2)
begin
  w
rescue ArgumentError => e
  puts e.message
end
begin
  v(1, 2)
rescue ArgumentError => e
  puts e.message
end
m = method(:k)
puts m.name, m.inspect[/#<Method: [^(]*/], m.arity, m.call(3)

class C
  def k(a) = "c1 #{__method__} #{a}"
  def w(a) = k(a)
end
o = C.new
puts o.w(1)
class C
  def k(a) = "c2 #{__method__} #{a}"
end
puts o.w(2)
p C.instance_methods(false).sort, o.public_methods(false).sort
p C.method_defined?(:k), o.respond_to?(:k)
p C.instance_method(:k).name
puts C.instance_method(:k).inspect[/#<UnboundMethod: [^(]*/]
puts o.send(:k, 3), o.public_send(:k, 4), o.method(:k).owner

# a program method whose name the redefined one's C name would take
def j_entry = :taken
def j = 1
def via_j = j
p via_j, j_entry
def j = 2
p via_j, j_entry
def i__entry = :taken
def i = 1
def via_i = i
p via_i, i__entry
def i = 2
p via_i, i__entry
