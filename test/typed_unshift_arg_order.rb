# unshift and prepend on an Integer or a String Array evaluate every
# argument, left to right, before the Array changes, as CRuby does and as the
# Float Array already did.
# each String argument stays alive while the next one allocates
acc = 0
200.times do |i|
  r = ["x"].unshift("#{i}a#{i}", ("#{i}".reverse + "b"), "c#{i * 2}")
  acc += r.map { |w| w.size }.sum
end
p acc
$log = []
def f(n)
  $log << n
  n
end
a = [1, 2, 3]
a.unshift((f(7); 70), (f(8); 80))
p a
p $log
s = ["x"]
$log = []
s.unshift(($log << s.length; "p"), ($log << s.length; "q"))
p s
p $log
$log = []
s.prepend("#{f(1)}a", "#{f(2)}b")
p [s, $log]
# an argument that raises leaves the Array as it was
def boom(n) = n == 2 ? raise("no #{n}") : n
b = [0]
begin
  b.unshift((boom(2); 1), 5)
rescue => e
  p [b, e.message]
end
begin
  s.unshift("#{boom(1)}a", "#{boom(2)}b")
rescue => e
  p [s, e.message]
end
