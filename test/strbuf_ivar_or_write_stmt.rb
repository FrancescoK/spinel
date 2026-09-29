# `@buf ||= +""` as a statement on an ivar that a local alias appends
# through (a shared-handle String slot) stores the String.

class Lazy
  def add(x)
    @buf ||= +""
    b = @buf
    b << x
    self
  end
  def s; @buf; end
end
w = Lazy.new
w.add("a").add("b")
p w.s

class NilFirst
  def initialize; @buf = nil; end
  def add(x)
    @buf ||= +"<"
    b = @buf
    b << x
    self
  end
  def s; @buf; end
end
w = NilFirst.new
p w.s
w.add("a").add("b")
p w.s

class AndWrite
  def initialize; @buf = +"x"; end
  def add(x)
    @buf &&= +"y"
    b = @buf
    b << x
    self
  end
  def s; @buf; end
end
p AndWrite.new.add("z").s
