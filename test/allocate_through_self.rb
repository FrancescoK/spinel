# `allocate` on the class a method runs for: bare or `self.allocate` in a
# class method (a subclass calling the inherited method gets its own
# class), and `self.class.allocate` in an instance method -- the shape
# the pure-Ruby Date uses to build a Date or a DateTime without running
# initialize.
class Day
  class << self
    def from_jd(jd) = build(jd)

    private

    def build(jd, frac = nil)
      obj = allocate
      obj.__send__(:init_from_jd, jd, frac)
      obj
    end
  end

  def self.plain(jd)
    o = self.allocate
    o.__send__(:init_from_jd, jd, nil)
    o
  end

  def init_from_jd(jd, frac)
    @jd = jd
    @frac = frac
  end
  private :init_from_jd

  attr_reader :jd, :frac

  def succ = self.class.__send__(:build, @jd + 1)

  def dup_bare
    o = self.class.allocate
    o.__send__(:init_from_jd, @jd, @frac)
    o
  end

  def inspect = "#<#{self.class} #{@jd}#{" +#{@frac}" if @frac}>"
end

class DayTime < Day
  def hour = (@frac || 0) * 24
end

class Leaf
  def copy = self.class.allocate
  def self.fresh = allocate
end

d = Day.from_jd(10)
t = DayTime.from_jd(20)
p d, t, d.succ, t.succ, t.succ.hour
p Day.plain(1), DayTime.plain(2), DayTime.plain(2).class
p d.dup_bare, t.dup_bare, t.dup_bare.class
p Leaf.new.copy.class, Leaf.fresh.class
u = Day.allocate
p u.jd, u.frac
