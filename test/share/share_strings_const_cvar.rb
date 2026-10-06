# Flag-only: without the flag (as on master) each read is a copy and misses the change.
# A constant or a class variable the rule shares holds the shared handle:
# a second name bound from it sees a change through the slot.
X = +"x"
y = X
y << "1"
p X
module M
  Y = +"y"
end
z = M::Y
z << "2"
p M::Y
class C
  @@v = +"v"
  def self.add(x) = @@v << x
  def self.alias_add
    w = @@v
    add("3")
    w
  end
end
p C.alias_add
