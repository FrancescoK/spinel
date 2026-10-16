# A multiple assignment that sends a boxed String (a poly Array's element)
# to an instance variable an --rbs signature types String or String? took
# the sp_RbVal temp as it was: C that did not compile, in both builds. The
# slot takes what a plain write of the box does, a box holding a String
# the String and a boxed nil the String? slot's nil, so each ivar is a
# String the callee can append to.
# spinel: rbs-seed-check
class MbsiHold
  def initialize(v, w, n, x)
    @z, @w = v, w
    @n, @m = n, x
  end

  def bump
    @z << "z"
    @w << "w"
    @m << "m"
  end

  def show
    p [@z, @w, @n, @m]
  end

  def swap(v, n)
    @z, @n = n, v
  end
end

a = +"a"
b = +"b"
c = +"c"
h = MbsiHold.new([a, 1][0], [b, 2][0], [nil, 3][0], [c, 4][0])
h.bump
h.show
h.swap([+"s", 5][0], [nil, 6][0])
h.show
