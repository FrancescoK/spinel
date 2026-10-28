# A frozen String Array stored into a slot that also holds other kinds
# stays frozen: frozen? answers true and a push raises FrozenError.
class H
  def initialize
    @b = ["x"].freeze
    @d = "s,t".split(",").freeze
    @u = ["open"]
  end

  def wide = @b.concat([])
  def fr = [@b.frozen?, @d.frozen?, @u.frozen?]

  def add
    @b.push("y")
  rescue FrozenError => e
    e.class
  end

  def addd
    @d.push(1)
  rescue FrozenError => e
    e.class
  end

  def addu = @u.push(2)
  def all = [@b, @d, @u]
end

h = H.new
begin
  h.wide
rescue FrozenError => e
  p e.class
end
p h.fr
p h.add
p h.addd
h.addu
p h.all
