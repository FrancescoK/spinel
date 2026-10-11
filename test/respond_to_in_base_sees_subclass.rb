# A method the base class runs answers respond_to? for the subclass the
# object really is: a servlet base dispatching `do_` + the request method
class Base
  def probe(n) = respond_to?(n)
  def probe_all(n) = respond_to?(n, true)
  def has_x? = respond_to?(:x)
end
class SubA < Base
  def x = 1
  private def secret = 2
end
class SubB < Base
  attr_accessor :y
end
class SubC < SubA
  undef_method :x
end
[Base.new, SubA.new, SubB.new, SubC.new].each do |o|
  p [o.class, o.has_x?, o.probe(:x), o.probe("y="), o.probe(:secret), o.probe_all(:secret)]
end
def pick(i) = [Base.new, SubA.new, nil][i]
3.times do |i|
  v = pick(i)
  p v.respond_to?(:x)
end
s = Base.new
def s.x = 9
p s.has_x?

class Servlet
  def service(m)
    name = "do_" + m
    respond_to?(name) ? __send__(name, m) : "unsupported #{m}"
  end
end
class ProcServlet < Servlet
  def do_GET(m) = "handled #{m}"
  alias do_POST do_GET
end
%w[GET POST PUT].each { |m| puts ProcServlet.new.service(m) }
# inside a block and a lambda the base method keeps the subclass's self
class Base
  def each_probe(names) = names.map { |n| respond_to?(n) }
  def later = -> { respond_to?(:x) }
end
p SubA.new.each_probe([:x, :y]), SubB.new.each_probe([:x, :y])
p SubA.new.later.call, Base.new.later.call
# a module method answers for the class that includes it; an Array
# subclass answers Array's names on self too
module Probe
  def has?(n) = respond_to?(n)
end
class WithA1; include Probe; def a1 = 1; end
class WithoutA1; include Probe; end
p WithA1.new.has?(:a1), WithoutA1.new.has?(:a1)
class Sized < Base; def size = 3; end
class List < Array; def sized? = respond_to?(:size); end
p Base.new.respond_to?(:size), Sized.new.respond_to?(:size), List.new.sized?
# receiverless, an Enumerable or Comparable includer answers their names
class Bag
  include Enumerable
  def each = yield(1)
  def maps? = respond_to?(:map)
end
class SubBag < Bag; end
class Pt
  include Comparable
  def <=>(o) = 0
  def between_ok? = respond_to?(:between?)
end
p Bag.new.maps?, SubBag.new.maps?, Pt.new.between_ok?
