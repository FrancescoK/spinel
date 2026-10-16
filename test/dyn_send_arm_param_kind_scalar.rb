# A computed-name `send` in a superclass method dispatches on boxed self, whose
# arms include every class defining the candidate name. An unrelated class's
# method of that name whose parameter is a scalar and whose argument is a
# builtin pointer kind, or the other way round, has its arm dropped: a Regexp
# into an Integer parameter, an Integer into a Regexp parameter. It was kept,
# and the C call passed a pointer where an integer was expected or the reverse.
class Other
  def bump(n) = n + 1
  def show(re) = re.source
end
class Base
  def handle(name, x) = send(name, x)
  def handle_int(name, n) = send(name, n)
end
class Child < Base
  def bump = "b"
  def show = "s"
  def src(re) = re.source
  def twice(n) = n * 2
end
p Other.new.bump(1)
p Other.new.show(/cd/)
p Child.new.bump
p Child.new.show
p Child.new.handle("src".to_sym, /ab/)
p Child.new.handle_int("twice".to_sym, 21)
