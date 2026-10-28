# The attribute forms the load record holds (--dump-load-record,
# record_attr_forms_main.rb.load-record): `attr`, an attr form a
# visibility word takes (`private attr_reader :b`, which defines b and
# makes it private), and one whose value the class body uses, written to a
# local or passed to a call, each where its statement runs.
class A
  attr :a
  private attr_reader :b
  r = attr_writer :c
  p r
  p(attr_reader :e)
  def initialize; @a = 1; @b = 2; @c = 3; @e = 5; end
  def peek = b
end
o = A.new
o.c = 30
p o.a, o.e, o.peek
p A.public_instance_methods(false).sort
p A.private_instance_methods(false).sort
