# An array of one class stays unboxed when the block of a walk or a filter
# holds another block. The inner block can be inlined (find, any?, each,
# times), or it can become a proc that keeps the element after the walk.

class Mob
  attr_reader :x, :hp
  def initialize(x) = (@x = x; @hp = 3)
  def contains?(x) = (@x - x).abs < 1.0
  def hit(d) = (@hp -= d)
end

class Arrow
  attr_reader :x
  def initialize(x) = (@x = x; @alive = true)
  def fly = (@x += 1.0)
  def vanish = (@alive = false)
  def alive? = @alive
end

# The shape of a game loop: each arrow flies, then looks for a mob it hits.
class Volley
  def initialize
    @mobs = [Mob.new(3.0), Mob.new(7.0)]
    @arrows = []
    @log = []
  end

  def shoot(x) = (@arrows << Arrow.new(x); nil)

  def update
    @arrows.each do |a|
      a.fly
      m = @mobs.find { |mob| mob.contains?(a.x) }
      if m
        m.hit(1)
        @log << a.x.to_i
        a.vanish
      end
    end
    @arrows.select!(&:alive?)
    nil
  end

  def report = [@arrows.size, @log, @mobs.map(&:hp)]
end

v = Volley.new
v.shoot(0.0); v.shoot(5.5); v.shoot(-10.0)
5.times { v.update }
p v.report

class Pt
  attr_reader :v
  def initialize(v) = (@v = v)
  def twice = @v * 2
end

class Keeper
  def initialize = (@kept = [])
  def keep(&blk) = (@kept << blk; nil)
  def call_all = @kept.map(&:call)
  def with(k) = yield(k)
end

# Inner blocks that become procs and keep the element after the walk ends.
class Board
  def initialize
    @pts = [Pt.new(1), Pt.new(2), Pt.new(3)]
    @procs = []
    @keeper = Keeper.new
  end

  def add(v) = (@pts << Pt.new(v); nil)

  def capture
    @pts.each { |pt| @procs << proc { pt.twice } }
    @pts.each { |pt| @procs << -> { pt.v + 100 } }
    @pts.each { |pt| @keeper.keep { pt.v * 10 } }
    @pts.each { |pt| @procs << proc { @keeper.with(1000) { |k| pt.v + k } } }
    nil
  end

  def reassign
    @pts.each do |pt|
      [1].each { |_| pt = Pt.new(pt.v + 50) }
      @procs << proc { pt.v }
    end
    nil
  end

  def inline
    near = []
    @pts.each { |pt| near << [3, 1, 2].sort_by { |k| (k - pt.v).abs }.first }
    s = 0
    @pts.each { |pt| 3.times { |i| s += pt.v * i } }
    pairs = []
    @pts.each_with_index do |a, i|
      ((i + 1)...@pts.size).each { |j| pairs << a.v * 10 + @pts[j].v }
    end
    [near, s, pairs]
  end

  # A walk or a filter whose block is a proc: map, each_with_index, select.
  def lifted
    held = @pts.map { |pt| proc { pt } }
    @pts.each_with_index { |pt, i| held << -> { Pt.new(pt.v * 100 + i) } }
    odd = @pts.select { |pt| held << proc { pt }; pt.v.odd? }
    [held, odd.map(&:v)]
  end

  def keep_odd
    @pts.reject! { |pt| [2, 4].any? { |k| k == pt.v } }
    nil
  end

  # A block that a method stores, inside map and the filters. In the
  # second half the block writes the element parameter, so it stays boxed.
  def stored
    out = @pts.map { |pt| @keeper.keep { pt.v + 200 }; pt.v }
    kept = @pts.select { |pt| @keeper.keep { pt.v + 300 }; pt.v > 1 }
    gone = @pts.reject { |pt| @keeper.keep { pt.v + 400 }; pt.v > 1 }
    @pts.select! { |pt| @keeper.keep { pt.v + 500 }; true }
    @pts.reject! { |pt| @keeper.keep { pt.v + 600 }; false }
    out += @pts.map { |pt| @keeper.keep { pt.v + 700 }; pt = Pt.new(0) if pt.v > 2; pt.v }
    held = @pts.select { |pt| @keeper.keep { pt.v + 800 }; pt = Pt.new(0) if pt.v > 2; true }
    @pts.select! { |pt| @keeper.keep { pt.v + 900 }; pt = Pt.new(0) if pt.v > 2; true }
    @pts.reject! { |pt| @keeper.keep { pt.v + 1000 }; pt = Pt.new(0) if pt.v > 2; false }
    [out, kept.map { |pt| pt.v }, gone.map { |pt| pt.v }, held.map { |pt| pt.v }]
  end

  # A proc that holds the element parameter, which the block then gives an
  # Integer or a Float. The proc sees the new value.
  def retyped
    held = []
    @pts.each { |pt| held << proc { pt }; pt = 5 if pt.v > 1 }
    ms = @pts.map { |pt| held << -> { pt }; pt = 6; pt * 2 }
    kept = @pts.select { |pt| held << proc { pt }; pt = 7 if pt.v > 1; true }
    gone = @pts.reject { |pt| held << -> { pt }; pt = 8.5; false }
    @pts.select! { |pt| held << proc { pt }; pt = 9; true }
    @pts.reject! { |pt| held << -> { pt }; pt = 10.5 if pt.v > 1; false }
    [held, ms, kept.map(&:v), gone.map(&:v)]
  end

  def run = @procs.map(&:call) + @keeper.call_all
  def vs = @pts.map(&:v)
end

b = Board.new
b.add(4)
b.capture
p b.inline
held, odd = b.lifted
p odd
b.reassign
b.keep_odd
p b.vs
p b.stored
retyped, *rest = b.retyped
p rest
# The walks are over; the procs still hold the elements, also the ones
# that the filter removed.
GC.start
p b.run
p held.map { |pr| pr.call.v }
p(retyped.map { |pr| x = pr.call; x.is_a?(Pt) ? "Pt#{x.v}" : x })

# The same at the top level, where a proc holds the element parameter of a
# walk or a filter over a local array, and the block then writes an Integer
# or a Float to the parameter.
keep = []
pts = [Pt.new(1), Pt.new(2), Pt.new(3)]
pts.each { |pt| keep << proc { pt }; pt = 5 if pt.v > 1 }
twice = pts.map { |pt| keep << -> { pt }; pt = 6; pt * 2 }
kept = pts.select { |pt| keep << proc { pt }; pt = 7 if pt.v > 1; true }
gone = pts.reject { |pt| keep << -> { pt }; pt = 8.5; false }
pts.select! { |pt| keep << proc { pt }; pt = 9; true }
pts.reject! { |pt| keep << -> { pt }; pt = 10.5 if pt.v > 1; false }
p twice, kept.map(&:v), gone.map(&:v), pts.map(&:v)
GC.start
p(keep.map { |pr| x = pr.call; x.is_a?(Pt) ? "Pt#{x.v}" : x })
