# instance_exec's arguments are the caller's: `O.new.instance_exec(@x) { |a| }`
# passes the caller's @x, and only the block runs with self switched to the
# receiver. The splice read every argument after the switch, so it passed
# O's @x, and where O had no @x the C did not build. The block's own
# defaults, and a trampoline's own arguments, still read the receiver.
# spinel: gc-minor
class O
  def initialize; @x = 99; @y = 98; @s = "o"; end
  def run(v, &b) = instance_exec(@x, v, &b)
end
class P; end

class T
  def initialize; @x = 1; @y = 2; @s = "t"; @h = {k: 3}; @a = [4, 5]; end
  def mx = @x + 10
  def bump = (@x += 1)

  def go
    O.new.instance_exec(@x) { |a| p [a, @x] }
    O.new.instance_exec(@x, @y) { |a, b| p [a, b] }
    P.new.instance_exec(@x) { |a| p a }
    O.new.instance_exec(self) { |t| p t.class }
    O.new.instance_exec(mx) { |a| p a }
    O.new.instance_exec(-> { @x }) { |l| p [l.call, @x] }
    # splats, keywords and numbered params
    O.new.instance_exec(*@a, @x) { |a, b, c| p [a, b, c, @y] }
    O.new.instance_exec(k: @x) { |k:| p k }
    O.new.instance_exec(**@h) { |k:| p k }
    O.new.instance_exec(@x, k: @y) { |a, k:| p [a, k, @x] }
    O.new.instance_exec(@s) { p [_1, @s] }
    O.new.instance_exec(@s) { p [it, @s] }
    # an argument with an effect runs once, before the block
    O.new.instance_exec(bump) { |a| p [a, @x] }
    p @x
    # a read a later argument rebinds binds what it read first
    y = 1
    O.new.instance_exec(y, (y = 5)) { |a, b| p [a, b] }
    x = 1
    O.new.instance_exec(x, (x = mx)) { |a, b| p [a, b] }
    # the block's defaults read the receiver
    O.new.instance_exec(@y) { |b, a = @x| p [b, a] }
    O.new.instance_exec(j: @y) { |j:, k: @x| p [j, k] }
    # as a value, nested, and on a receiver of two classes
    p O.new.instance_exec(@x) { |a| a + @x }
    O.new.instance_exec(@x) { |a| P.new.instance_exec(@x, a) { |b, c| p [b, c] } }
    [O.new, P.new][0].instance_exec(@x) { |a| p [a, @x] }
    # instance_eval hands the block the receiver
    O.new.instance_eval { |o| p [o.class, @x] }
    # a trampoline's own arguments read the receiver, the ones it takes the caller
    O.new.run(@y) { |a, b| p [a, b] }
    fwd { |a| p [:fwd, a] }
    # arguments that allocate, bound while the block allocates
    3.times { |i| O.new.instance_exec(@x + i, "s#{i}" * 2) { |a, s| p [a, s + "!", @x] } }
  end

  def fwd(&b) = O.new.instance_exec(@x, &b)

  def self.go = O.new.instance_exec(@x) { |a| p [:cm, a, @x] }
  @x = 7
end

T.new.go
T.go
