# A local bound to an ivar write (`b = (@buf ||= +"")`, `b = @buf = +""`)
# is the ivar's String itself: appending through the local shows in the ivar.

class Memo
  def add(x)
    b = (@buf ||= +"")
    b << x
    self
  end
  def s; @buf; end
end
p Memo.new.add("a").add("b").s

class Bare
  def add(x)
    b = @buf ||= +""
    b << x << "!"
    self
  end
  def s; @buf; end
end
p Bare.new.add("a").add("b").s

class Seeded
  def initialize; @buf = +"i"; end
  def add(x)
    b = (@buf ||= +"")
    b << x
    self
  end
  def s; @buf; end
end
p Seeded.new.add("a").add("b").s

class Reset
  def reset
    b = (@buf = +"")
    b << "r"
    self
  end
  def s; @buf; end
end
p Reset.new.reset.s

class Kept
  def initialize; @buf = +"k"; end
  def keep
    b = (@buf &&= +"x")
    b << "y"
    self
  end
  def s; @buf; end
end
p Kept.new.keep.s

@top = nil
def top_add(x)
  b = (@top ||= +"")
  b << x
end
top_add("a")
top_add("b")
p @top
