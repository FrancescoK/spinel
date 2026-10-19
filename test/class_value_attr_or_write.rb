# `||=` and `&&=` on an attribute of a Class value: `self.class.memo ||= v`
# in a module that several classes include, each with its own class-level
# accessor, and a class picked at run time. The receiver is evaluated once,
# as CRuby evaluates it, even where `class` is a method of the program's.
module MinSize
  def largest(style, n)
    self.class.largest ||= -Float::INFINITY
    self.class.largest = n if style == :brackets && n > self.class.largest
    self.class.largest
  end

  def tag!
    self.class.label &&= "#{self.class.label}!"
  end
end

class Sym
  include MinSize
  class << self
    attr_accessor :largest, :label
  end
end

class Word
  include MinSize
  class << self
    attr_accessor :largest, :label
  end
end

s = Sym.new
p s.largest(:percent, 3)
p s.largest(:brackets, 2)
p s.largest(:brackets, 1)
p Word.new.largest(:brackets, 5)
p [Sym.largest, Word.largest]
p s.tag!
Sym.label = "sym"
Word.label = "word"
p s.tag!, Word.new.tag!
p [Sym.label, Word.label]

k = ARGV.size > 3 ? Sym : Word
k.largest ||= 0
p k.largest
k.largest &&= k.largest + 1
p k.largest

# a `class` of the program's own runs once for the reader and the writer
class Counted
  class << self
    attr_accessor :memo
  end
  @calls = 0
  def self.calls = @calls
  def self.bump = @calls += 1
  def class
    Counted.bump
    Counted
  end

  def fill = self.class.memo ||= :filled
end
p Counted.new.fill, Counted.calls
p Counted.new.fill, Counted.calls
