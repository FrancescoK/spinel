# defined?(@x) on a class-level ivar (a class method's, a class body's, the
# top level's) is nil until a write runs, even a write of nil.
module A
  def self.d; defined?(@x).inspect; end
  def self.orw; @x ||= nil; end
  def self.andw; @x &&= 1; end
  def self.setnil; @x = nil; end
  def self.expr; y = (@x = nil); y; end
  def self.blk; [1].each { @x = nil }; end
end
p A.d; A.andw; p A.d; A.orw; p A.d
module B
  def self.d; defined?(@a) ? "a" : "-"; end
  def self.e; defined?(@b) ? "b" : "-"; end
  def self.m; @a, @b = nil, nil; end
end
p [B.d, B.e]; B.m; p [B.d, B.e]
module C1
  def self.d; defined?(@x).inspect; end
  def self.blk; [1].each { @x = nil }; end
end
p C1.d; C1.blk; p C1.d
module C2
  def self.d; defined?(@x).inspect; end
  def self.expr; y = (@x = nil); y; end
end
p C2.d; p C2.expr; p C2.d
class S
  class << self; attr_writer :w; attr_reader :w; end
  def self.d; defined?(@w).inspect; end
end
p S.d; S.w = nil; p S.d
class T
  def self.d; defined?(@v).inspect; end
end
p T.d; T.instance_variable_set(:@v, nil); p T.d
class N
  @n = nil
  def self.d; defined?(@n).inspect; end
  def self.d2; defined?(@m).inspect; end
end
p N.d, N.d2
class I
  def self.d; defined?(@i).inspect; end
  def self.bump; @i = 0 unless defined?(@i); @i += 1; end
end
p I.d; p I.bump; p I.bump; p I.d
class Str
  def self.d; defined?(@s).inspect; end
  def self.s; @s = "x" if false; @s; end
  def self.set; @s = "y"; end
end
p Str.d; p Str.s; p Str.d; Str.set; p Str.d
p defined?(@top)
@top = nil
p defined?(@top)
def tm; defined?(@tt).inspect; end
def ts; @tt = nil; end
p tm; ts; p tm
class Body
  @q = nil if ARGV.size > 3
  p defined?(@q)
  [1].each { p defined?(@q) }
  @q = nil
  p defined?(@q)
  [1].each { p defined?(@q) }
  def self.d; defined?(@q).inspect; end
end
p Body.d
class Sb
  def self.d; defined?(@s).inspect; end
  def self.w2; t = (@s ||= +"z"); t << "y"; t; end
end
p Sb.d; Sb.w2; p Sb.d
def tw2; t = (@ts ||= +"z"); t << "y"; t; end
p defined?(@ts); tw2; p defined?(@ts)
class Pb
  p defined?((@x))
  @x = nil
  p defined?((@x))
end
