# The class's own define_method answers the call, so nothing is defined:
# CRuby prints "plain", "mine show", "plain".
class R
  def self.define_method(name) = "mine #{name}"
  def show = "plain"
  def self.install! = define_method(:show) { "fancy" }
end
p R.new.show
p R.install!
p R.new.show
