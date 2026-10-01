# method(name).call(args) with a name known only at run time calls the method
# (it compiled to an unconditional NoMethodError raise, #6484)
class Greeter
  def greet(x) = "hi #{x}"
  def by_name(x) = "name=#{x}"
  def by_tag(x) = "tag=#{x}"
  def run(name) = method(name).call("a")
  def all = %w[name tag].map { |k| method("by_#{k}".to_sym).call("a") }
  def shout(name) = method(name).call("b").upcase
  def via(o, name) = o.method(name).call("c")
end
g = Greeter.new
p g.run(:greet)
puts g.run(:greet)
p g.all
p g.shout(:greet)
p g.via(Greeter.new, :by_tag)
