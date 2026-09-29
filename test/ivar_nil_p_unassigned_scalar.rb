# `@x.nil?` on an ivar whose slot is a Symbol, read before any write reached
# it: the slot starts as the (sp_sym)-1 nil sentinel, which a real symbol
# never is, yet `nil?` folded to false with the value types -- an Integer or
# String slot already asked its own sentinel. A class_attribute's instance
# reader (`@x.nil? ? self.class.x : @x`) read the unset instance value as
# set. (A Float ivar is not initialized to its nil sentinel; not covered.)
class T
  attr_writer :sym, :int, :str
  def probe = [@sym.nil?, @int.nil?, @str.nil?]
  def sym_or(d) = @sym.nil? ? d : @sym
end
t = T.new
p t.probe
p t.sym_or(:default)
t.sym = :x
t.int = 1
t.str = "s"
p t.probe
p t.sym_or(:default)
u = T.new
u.sym = :set
p u.sym_or(:default), u.probe
