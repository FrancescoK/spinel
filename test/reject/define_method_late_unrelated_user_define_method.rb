# A define_method of the program's own, even in an unrelated class, may be
# the one a call reaches, so the call is refused: CRuby prints "helper x",
# "plain", "fancy".
class Helper
  def define_method(name) = "helper #{name}"
end
p Helper.new.define_method(:x)
class R
  def show(x) = "plain"
  def self.make_fancy! = define_method(:show) { |x| "fancy" }
end
p R.new.show(1)
R.make_fancy!
p R.new.show(2)
