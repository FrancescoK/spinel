# A seed contradicted on a container's ELEMENT type used to fall through to cc,
# which named sp_PolyArray / sp_IntArray -- types the author cannot connect back
# to the `Array[untyped]` they wrote. The two array kinds are different C
# structs and the emitter does not rebuild one from the other at a boundary
# (that would hand back a copy, so writes through the getter would stop
# reaching the receiver's own array), so this is a real contradiction and
# spinel names it in the RBS's own vocabulary (#4151).
# spinel: rbs-seed-contradicted-return
class Box
  def initialize
    @rows = [1, 2, 3]
  end

  def rows
    @rows
  end
end

p Box.new.rows.length
