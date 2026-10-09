# spinel: share
# spinel: gc-stress
# remove_instance_variable answers the value the ivar held and leaves it
# unassigned and nil; an ivar never assigned, or already removed, raises
# NameError, as CRuby's does.

class Pt
  def initialize(x) = (@x = x)
  def set_y = (@y = 2)
  def y = @y
end
pt = Pt.new(1)
begin
  p pt.remove_instance_variable(:@y)
rescue NameError => e
  puts e.message
end
pt.set_y
p pt.remove_instance_variable(:@y)
p pt.instance_variables, pt.instance_variable_defined?(:@y), pt.y
pt.set_y
p pt.instance_variables

class R
  def initialize(s) = (@s = s)
  def drop = remove_instance_variable(:@s)
  def s = @s
  def set(v)
    @s = v
  end
end
r = R.new("a" + "b")
p r.drop
p r.instance_variables, r.s
begin
  r.drop
rescue NameError => e
  puts e.message
end
r.set(nil)
p r.instance_variables, r.drop, r.instance_variables
r.set("z" * 3)
puts r.inspect.gsub(/0x\h+/, "0x")
p R.new(nil).remove_instance_variable(:@s)

# the NameError names the ivar
begin
  R.new(1).remove_instance_variable(:@nope)
rescue NameError => e
  p e.name, e.message
end
r2 = R.new(1)
r2.drop
begin
  r2.drop
rescue NameError => e
  p e.name
end
