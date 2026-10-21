# spinel: gc-stress
# A receiver typed as a class can hold an instance of a descendant (`self` in
# an inherited method), and a multiple assignment's writer target stores
# through the descendant's own `x=`, as the single setter does. Its parameter
# takes the boxed element of a nested (a, b) target as the base's does.

class Base
  attr_reader :v
  def b=(x)
    @v = x
  end

  def flat
    x, self.b = 1, 5.5
    [x, @v]
  end

  def nested
    (x, self.b), y = [1, 5.5], 3
    [x, @v, y]
  end

  def via_local
    me = self
    (x, me.b), y = [[2, 6.5], 3]
    [x, @v, y]
  end
end

class Sub < Base
  def b=(x)
    @v = x + 100
  end
end

class Acc
  attr_accessor :w
  attr_reader :log

  def run
    x, self.w = 1, 2.5
    [x, @w]
  end
end

class AccSub < Acc
  def w=(x)
    @w = [x]
  end
end

class Wr
  def w=(x)
    @w = x
  end

  def run
    (x, self.w), y = [1, 4], 3
    [x, @w, y]
  end
end

class WrSub < Wr
  attr_writer :w
end

s = Sub.new
s.b = 1
p s.flat
p s.nested
p s.via_local
p Base.new.flat
p Base.new.nested
p AccSub.new.run
p Acc.new.run
p WrSub.new.run
p Wr.new.run
