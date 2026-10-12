# An Integer ivar's between? went onto the Integer copy of between?. The
# included module's chained write, never called, widened the ivar only in
# the backstops after the fixpoint, and the copy was called with the boxed
# ivar.

module Saved
  def load(input)
    @line = @out = input.int(@line)
  end
end

class Vic
  include Saved

  def initialize
    @line = 0
    @out = 0
    @vsync = 3
  end

  def step = @line += 1
  def near? = @line.between?(@vsync, @vsync + 2)
  def wide? = @line.clamp(@vsync, @vsync + 2) == @line
end

v = Vic.new
v.step
p v.near?
p v.wide?
4.times { v.step }
p v.near?
p v.wide?
3.times { v.step }
p v.near?
