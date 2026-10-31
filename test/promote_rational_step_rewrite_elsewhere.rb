# A computed Rational in a local or an ivar is still known as one when a
# variable of the same name is rewritten (`x += v`, `@step ||= v`) in
# another method or class: the rewrite is that slot's, not this one's. A
# rewrite anywhere by name hid it, and the Integer step by it walked a step
# of 0 and raised (#10655's review).
def other
  x = 1
  x += 2
  x
end

def walk
  x = 1r / 2
  1.step(2, x).to_a
end

class Counter
  def bump
    @step ||= 0
    @step += 1
  end
end

class Walker
  def initialize
    @step = 1r / 3
  end

  def run
    0.step(1, @step).to_a
  end
end

p other, walk
c = Counter.new
c.bump
p c.bump, Walker.new.run
