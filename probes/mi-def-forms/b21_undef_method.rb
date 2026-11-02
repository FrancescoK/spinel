class P
  def a = 1
  def b = 2
  def c = 3
end
class Q < P
  p new.respond_to?(:a)
  undef_method :a, "b"
  p new.respond_to?(:a), new.respond_to?(:b)
  self.undef_method :c
  def a = 10
end
p Q.new.a, Q.new.respond_to?(:c)
begin
  Q.new.b
rescue NoMethodError => e
  puts e.message
end
p P.new.b
