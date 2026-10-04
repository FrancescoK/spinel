# A method inlined into a poly dispatch arm (Player#frame, reached through
# an Array of two player classes) whose body inlines another call with a
# block (@m.mix(&)): the inner call binds its own receiver, not the
# arm's cast. It bound the arm's sp_Player * as its sp_Mixer * self and
# the C did not build.
class Bag
  def initialize(xs) = @xs = xs
  def emit(k, &) = @xs.each { |x| yield x * k }
end
class Pair
  def initialize(a, b) = (@a = a; @b = b)
  def emit(k, &blk) = (blk.call(@a * k); blk.call(@b * k))
end
class Mixer
  def initialize(outs) = @outs = outs
  def mix(k, &)
    @outs.each { |o| o.emit(k, &) }
  end
end
class Player
  def initialize(m) = @m = m
  def frame(&) = (@m.mix(10, &); 0)
end
class Player2
  def initialize(m) = @m = m
  def frame(&) = (@m.mix(100, &); 1)
end
out = []
[Player.new(Mixer.new([Bag.new([1]), Pair.new(2, 3)])), Player2.new(Mixer.new([Pair.new(4, 5), Bag.new([6])]))].each { |pl| pl.frame { |x| out << x } }
p out
