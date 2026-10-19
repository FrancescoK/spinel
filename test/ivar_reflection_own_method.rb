# A class of the program's own that defines instance_variable_get (or _set,
# instance_variable_defined?, instance_variables, remove_instance_variable)
# answers its instances' reflection with that method, wherever the class
# comes from (its own body, a module it includes, a superclass), on a
# receiver of its class and on one that can be of any class. The builtin
# reads the layout only for the classes without such a method, and a String
# it reads from an ivar is the ivar's String itself.
class Own
  def initialize
    @n = +"ow"
    @s = +"os"
  end
  def instance_variable_get(x) = +"mine"
  def instance_variable_set(x, v) = :own_set
  def instance_variable_defined?(x) = :own_def
  def instance_variables = [:own_vars]
  def remove_instance_variable(x) = :own_rm
end
class Fr
  def initialize(x) = (@s = x)
  def s = @s
end
module Reflect
  def instance_variable_get(x) = "refl"
end
class ViaMod
  include Reflect
  def initialize = (@s = +"vm")
end
class Sub < Own; end
class Err < StandardError
  def initialize(m)
    super(m)
    @s = +"err"
  end
  def instance_variable_get(x) = "errmine"
end

f = Fr.new(+"fr")
objs = [f, Own.new, ViaMod.new, Sub.new, 3, Fr.new(+"o2")]

o = Own.new
p o.instance_variable_get(:@n), o.instance_variable_set(:@n, 1), o.instance_variable_defined?(:@n)
p o.instance_variables, o.remove_instance_variable(:@n)
p ViaMod.new.instance_variable_get(:@s), Sub.new.instance_variable_get(:@n)
p Err.new("m").instance_variable_get(:@s)
nm = [:@n][ARGV.size]
p o.instance_variable_get(nm)

objs.each do |x|
  p x.instance_variable_get(:@s)
  p x.instance_variable_defined?(:@s)
  p x.instance_variables
end

a = objs.map { |x| x.instance_variable_get(:@s) }
p a
h = { k: objs[0].instance_variable_get(:@s) }
a[0] << "!" if a[0].is_a?(String)
p f.s, h[:k].equal?(f.s)
def pass(x) = x.instance_variable_get(:@s)
r = pass(f)
r << "?"
p f.s
p pass(objs[1])
@iv = objs[0].instance_variable_get(:@s)
@iv << "~"
p f.s
q = [objs[0], objs[1]].map { |x| x.instance_variable_get(:@s) }
p q
t = objs[0].then { |x| x.instance_variable_get(:@s) }
t << "@"
p f.s
p objs[1].instance_variable_set(:@s, 4)
p f.instance_variable_get(:@s)
p objs[ARGV.size].instance_variable_set(:@s, +"newv"), f.s
