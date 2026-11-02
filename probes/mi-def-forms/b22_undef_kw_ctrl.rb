class P
  def a = 1
end
class Q < P
  p new.respond_to?(:a)
  undef a
  def a = 10
end
p Q.new.a
