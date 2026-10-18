# `||=` and `&&=` on an attribute of a Class value: `self.class.memo ||= v`
# in a module that several classes include, each with its own class-level
# accessor or hand-written reader and writer, and a class picked at run
# time.
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
    attr_accessor :largest
    def label = @label
    def label=(v)
      @label = v.upcase
    end
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
