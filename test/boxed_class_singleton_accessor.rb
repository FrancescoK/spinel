# A call on a Class value held boxed (a block parameter over an Array of
# classes) reaches a `class << self` accessor, beside classes that answer
# the name by a class method of their own and alone.
class Sym
  class << self
    attr_accessor :label
  end
end

class Word
  class << self
    def label = @label

    def label=(v)
      @label = v.upcase
    end
  end
end

class Num
  def self.label = 42
end

class Tag
  class << self
    attr_reader :mark
    attr_writer :mark
  end
end

Sym.label = "s"
Word.label = "w"
p [Sym, Word, Num].map { |k| k.label }
[Sym, Word].each { |k| k.label = "#{k.name.downcase}!" }
p [Sym, Word].map(&:label)
p [Sym].map { |k| k.label }
Tag.mark = :m
p [Tag, Tag].map { |k| k.mark }
[Tag].each { |k| k.mark = [1, 2] }
p Tag.mark
begin
  [Num].each { |k| k.label = 1 }
rescue NoMethodError => e
  p e.message
end
