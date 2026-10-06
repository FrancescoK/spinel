# A local bound to a class method's ivar write (`t = (@s = +"a")`, `&&=`,
# `||=`) is that ivar's String, and an append through the ivar shows
# through the local. The ivar of a class method is its class's C global;
# the local took the handle of a `self->iv_s` that class has no field for,
# and the C did not build.
class K
  def self.run
    t = (@s = +"a"); @s << "!"; p t
    u = (@s &&= +"b"); @s << "?"; p u
  end
end
K.run
