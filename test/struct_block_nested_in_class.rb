# A Struct.new or Data.define block written in a class or module body runs
# with self the struct's class, as at the top level, not the class around
# it: its bare and self calls, class methods, attrs and define_methods are
# the struct's, while constants keep the lexical scope of the class around.
# The constant names the class only once the block has run.
ANON = /\A#<Class:0x\h+>\z/

class Outer
  N = 3
  def self.tag = :outer

  S = Struct.new(:a) do
    p self.members, self.class, self.equal?(Outer)
    p self.method_defined?(:a), self.ancestors.include?(Struct)
    p name, members, self.inspect.match?(ANON), "#{self}".match?(ANON)
    $kept = self
    def self.tag = :struct
    p tag
    def self.build = new(N)
    def scaled = a * N
    attr_accessor :extra
    if true
      define_method(:lit) { a + 10 }
    end
    define_method(:gone) { 0 } if false
    INNER = :outer_const
  end

  # a struct block in a struct block's: each node is the innermost one's
  T = Struct.new(:t) do
    U = Struct.new(:u) do
      p members
      def uu = u * 2
    end
    p self.members
    def tt = t * 3
  end
end

module Box
  D = Data.define(:x) do
    p self.members
    def self.origin = new(x: 0)
    def plus(o) = with(x: x + o.x)
    define_method(:twice) { x * 2 } unless false
  end
end

s = Outer::S.new(1)
s.extra = 5
p s.extra, s.scaled, s.lit, s.respond_to?(:gone)
p $kept.equal?(Outer::S), Outer::S.tag, Outer.tag
p Outer::S.build.scaled
p Outer.respond_to?(:build), Outer.method_defined?(:scaled), Outer.method_defined?(:lit)
p Outer::INNER
p Outer::T.new(1).tt, Outer::U.new(2).uu
p Outer::T.method_defined?(:uu), Outer::U.method_defined?(:tt)
p Box::D.origin.plus(Box::D.new(x: 5)), Box::D.new(x: 4).twice
