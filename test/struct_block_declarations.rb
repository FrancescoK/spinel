# attr_*, alias, alias_method, visibility and undef in a Struct.new /
# Data.define block apply to the class the block defines
S = Struct.new(:a) do
  attr_accessor :z
  def m = "m#{a}"
  alias n m
  alias_method :o, :m
  def hid = 1
  private :hid
  def uses_hid = hid + 1
  protected
  def prot = a
  public
  def cmp(other) = other.prot
  def gone = 2
  undef gone
end
s = S.new(1)
s.z = 4
p s.z
p s.n
p s.o
p s.uses_hid
p s.cmp(S.new(5))
begin
  s.hid
rescue NoMethodError => e
  puts e.message
end
begin
  s.prot
rescue NoMethodError => e
  puts e.message
end
begin
  s.gone
rescue NoMethodError => e
  puts e.message
end

D = Data.define(:a) do
  def twice = a * 2
  alias_method :dbl, :twice
  def secret = 5
  private :secret
end
d = D.new(a: 3)
p d.dbl
begin
  d.secret
rescue NoMethodError => e
  puts e.message
end

# a Struct held in a local
k = Struct.new(:a) do
  attr_accessor :z
  def m = a + 1
  alias n m
end
x = k.new(1)
x.z = 7
p x.z
p x.m
p x.n

# `private def` in the block, held in a constant and in a local
PD = Struct.new(:a) do
  private def hidden = a + 1
  def show = hidden
end
p PD.new(1).show
begin
  PD.new(1).hidden
rescue NoMethodError => e
  puts e.message
end
pk = Struct.new(:a) do
  protected def prot = a + 2
  def show = prot
end
p pk.new(1).show
p pk.new(1).respond_to?(:prot)
