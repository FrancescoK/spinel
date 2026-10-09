$log = +""
LOG2 = +""
class K
  @@c = +""
  def self.add(x) = (@@c << x; $log << x; LOG2 << x)
  def self.c = @@c
end
a = $log
b = LOG2
c = K.c
60.times do |i|
  K.add(i.to_s)
  junk = Array.new(10) { "w" * i }
end
p a.size, b.size, c.size, a.equal?($log), b.equal?(LOG2), c.equal?(K.c)
