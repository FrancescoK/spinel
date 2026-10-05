# A forwarder reached through a poly dispatch passes its anonymous `&` on
# from inside a block of its own (`@outputs.each { |o| o.each(&) }`). The
# inline it runs under holds the caller's block as a real proc; the
# dispatch over `o` built no proc for it and handed each arm NULL, and the
# Bag's each raised LocalJumpError.
class Bag
  def initialize(xs) = @xs = xs
  def each(&) = @xs.each(&)
end

class Stereo
  def initialize(outputs) = @outputs = outputs
  def mix(&)
    case @outputs.size
    when 1 then both(@outputs[0], &)
    else @outputs.each { |o| o.each(&) }
    end
  end
  def both(samples) = samples.each { |s| yield s; yield s }
end

class BarePlayer
  def initialize(stereo) = @stereo = stereo
  def frame(n, &) = (@stereo.mix(&); n)
end

class MachinePlayer
  def initialize(stereo) = @stereo = stereo
  def frame(n, &) = (@stereo.mix(&); n + 1)
end

class Recorder
  def initialize = @out = []
  attr_reader :out
  def run(pl) = pl.frame(0) { |x| @out << x }
end

r = Recorder.new
[BarePlayer.new(Stereo.new([[1, 2]])), MachinePlayer.new(Stereo.new([Bag.new([3]), [4]]))].each { |pl| r.run(pl) }
p r.out
