class V
  def initialize(n) = @n = n
  def a = @n
  def b(x, y) = @n + x + y
end
$i = 0
def mk = (puts "recv"; $i += 1; V.new($i))
def nm(s) = (puts "name"; s)
def ar(v) = (puts "arg"; v)
p mk.method(nm(:a)).call
p mk.send(nm(:b), ar(10), ar(100))
p mk.public_send(nm(:a))
p(false && mk.send(nm(:a)))
begin
  mk.method(nm(:zz))
rescue NameError => e
  puts e.message
end
begin
  mk.send(nm(:zz))
rescue NoMethodError => e
  puts e.class
end
p [1, 2].map { |k| mk.send(nm(:a)) + k }
