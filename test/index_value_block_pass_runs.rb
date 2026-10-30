# A value and a `&expr` block argument: the block is not used, but CRuby
# still evaluates expr once, after the receiver and the value.
def mk = (puts "made"; proc { true })
p [3, 2].index(2, &mk)
p [3, 2].rindex(2, &mk)
p [3, 2].find_index(2, &mk)
p [3, "a"].index("a", &mk)
p (1..3).find_index(2, &mk)
p({a: 1}.find_index([:a, 1], &mk))
p [3, 2].each.find_index(2, &mk)
def arr = (puts "recv"; [3, 2])
def val = (puts "val"; 2)
p arr.index(val, &mk)
x = [[3, 2], "s"][0]
p x.index(2, &mk)
p [3, 2].index(2, &method(:puts))
class K
  def index(v, &b) = b.call(v)
end
p K.new.index(5, &mk)
b = proc { |z| z == 2 }
p [3, 2].index(&b)
p [3, 2].index(2, &nil)
v = 2
a = [3, 2]
p a.index(v, &(v = 3; mk))
c = [3, 2]
p c.index(2, &(c = [2]; mk))
@a = [5, 6]
p @a.index(6, &(@a = [6]; mk))
# a runtime-name send keeps the arm for the name
n = ARGV.size > 5 ? :rindex : :index
p [3, 2].public_send(n, 2, &mk)
p [3, 2].send(n, 2, &mk)
f = ARGV.size > 5 ? :index : :find_index
p [3, 2].public_send(f, 2, &mk)
p K.new.public_send(n, 7, &mk)
