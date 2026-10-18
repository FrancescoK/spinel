# A call on a Class value held in a variable, where some classes answer it
# by a `class << self` accessor and others by a class method of their own:
# each class takes its own arm.
module Labeled
  def lab
    k = self.class
    k.label
  end

  def relabel(v)
    k = self.class
    k.label = v
    k.label
  end
end

class Sym
  include Labeled
  class << self
    attr_accessor :label
  end
end

class Word
  include Labeled
  class << self
    def label = @label

    def label=(v)
      @label = v.upcase
    end
  end
end

class Num
  include Labeled
  def self.label = 42
end

Sym.label = "s"
Word.label = "w"
p Sym.new.lab, Word.new.lab, Num.new.lab
p Sym.new.relabel("t"), Word.new.relabel("x")
def label_of(k) = k.label
p label_of(Sym), label_of(Word), label_of(Num)
def relabel(k, v)
  (k.label = v) && k.label
end
p relabel(Sym, "Sym!"), relabel(Word, "Word!")
p Sym.new.lab.size
