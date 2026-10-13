# A send whose name is an element of a table filled with built names -- a
# constant Hash whose default block stores interpolated Symbols, or a
# table a `[]=` fills with them -- dispatches over every method, not only
# the Symbol literals: the names it reaches are spelled by no literal.
class T
  M = Hash.new { |h, t| h[t] = :"on_#{t}" }
  def initialize = (@tab = {})
  def on_a(x) = "a #{x}"
  def on_b(x) = "b #{x}"
  def go(t, x) = send(M[t], x)
  def via_local(t, x)
    name = M[t]
    public_send(name, x)
  end
  def fill(t) = (@tab[t] = "on_#{t}".to_sym)
  def via_ivar(t, x) = __send__(@tab[t], x)
  def handle(name, x) = send(name, x)
  def via_param(t, x) = handle(M[t], x)
end
o = T.new
puts o.go(:a, 1), o.go(:b, 2)
puts o.via_local(:b, 3)
o.fill(:a)
puts o.via_ivar(:a, 4)
puts o.via_param(:a, 5)
begin
  o.go(:c, 6)
rescue NoMethodError => e
  puts e.name
end
