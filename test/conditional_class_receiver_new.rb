# A class picked by a conditional, or held in a global or class variable,
# constructs through the Class-value `new` dispatch with arguments.
class Tune
  def sid_model = 6581
end

class BarePlayer
  def initialize(tune, song: nil, sid_model: 6581)
    @song = song
    @m = sid_model
  end
  def to_s = "bare #{@song.inspect} #{@m}"
  def self.tag = "b"
end

class MachinePlayer
  def initialize(tune, song: 1, sid_model: 8580)
    @song = song
    @m = sid_model
  end
  def to_s = "machine #{@song.inspect} #{@m}"
  def self.tag = "m"
end

class A
  def initialize(x) = @x = x
  def to_s = "A#{@x}"
end

class B
  def initialize(x) = @x = x
  def to_s = "B#{@x}"
end

class Host
  def initialize(bare, song)
    @bare = bare
    @song = song
    @tune = Tune.new
    @sid_model = 6000
  end
  def bare? = @bare
  def player = @player ||= (bare? ? BarePlayer : MachinePlayer).new(@tune, song: @song, sid_model: @sid_model)
  def by_if = (if bare? then BarePlayer else MachinePlayer end).new(@tune, sid_model: 1)
  def by_case = (case @bare when true then BarePlayer else MachinePlayer end).new(@tune)
  def by_and_or = (@bare && BarePlayer || MachinePlayer).new(@tune, song: 9, sid_model: 2)
  def by_unless = (unless bare? then MachinePlayer else BarePlayer end).new(@tune, song: 4)
  def tag = (bare? ? BarePlayer : MachinePlayer).tag
end

[0, 1].each { |i| puts (i == 0 ? A : B).new(i) }

[true, false].each do |b|
  h = Host.new(b, 3)
  puts h.player, h.player.equal?(h.player), h.by_if, h.by_case, h.by_and_or, h.by_unless, h.tag
end

$klass = B
puts $klass.new(5)

class Holder
  @@klass = A
  def self.make(x) = @@klass.new(x)
end
puts Holder.make(6)
