# A boxed String subclass instance (one read out of an Array) calls the
# class's own method of a String name, as a plain one does. A plain
# String and a shared String in the same slot still call String's.
class S < String
  def length = -1
  def size = -2
  def bytesize = 77
  def empty? = :e
  def to_sym = :own
  def start_with?(x) = :sw
  def include?(x) = :inc
  def center(n) = "C"
  def tag = "T"

  def []=(i, v)
    @set = v
  end

  def got = @set
end

class S2 < S; end

class R < String; end

class A < String
  attr_reader :size

  def initialize(s)
    super(s)
    @size = 99
  end
end

class Plain
  def length = 9
  def include?(x) = :pinc
end

x = [S.new("qq"), 1].first
p x.length, x.size, x.bytesize, x.empty?, x.to_sym
p x.start_with?("q"), x.include?("q"), x.center(5), x.tag, x.upcase
x[0] = "Z"
p x.got, x.length

y = [S2.new("w"), 1].first
p y.length, y.to_sym

z = [R.new("rr"), 1].first
p z.length, z.to_sym, z.include?("r"), z.empty?

s = +"ab"
s << "c"
w = [s, 1].first
w[0] = "W"
p w, w.length, w.include?("W"), w.to_sym

p [A.new("ab"), 1].first.size
[+"ab", Plain.new, x, z, :sym, [1, 2]].each { |e| p e.length }
[+"ab", Plain.new, x].each { |e| p e.include?("a") }
p String.try_convert(S.new("ab")).length
