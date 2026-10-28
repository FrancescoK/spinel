# An undef the load record holds under a constant condition (`undef b if
# true`, the else of `if false`) and in a reopened class removes the
# method; the arm a constant condition skips leaves it.
class P
  def a = 1
  def b = 2
  def c = 3
  def d = 4
  def e = 5
end
class Q < P
  undef_method :a
  undef b if true
  if false
    undef c
  else
    undef d
  end
end
class Q
  undef e
end
q = Q.new
[:a, :b, :c, :d, :e].each { |m| puts "#{m} #{q.respond_to?(m)}" }
begin; q.a; rescue NoMethodError => x; puts x.message; end
begin; q.e; rescue NoMethodError => x; puts x.message; end
puts q.c
p Q.instance_methods(false).sort
p Q.public_method_defined?(:d)
