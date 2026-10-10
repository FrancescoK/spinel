# A String Range held by a global, a constant, a class-level ivar or a
# class variable is marked with what it carries: its endpoint Strings, made
# on the spot, were swept while the slot still named them.
# spinel: gc-stress
n = 3
$gr = ("g"..(n.to_s * 2))
KR = ("k"..(n.to_s + "x"))
class Keeper
  @cr = nil
  @@vr = nil
  def self.set(i)
    @cr = ((i * 2).to_s..(i * 3).to_s)
    @@vr = ((i * 4).to_s..(i * 5).to_s)
  end
  def self.cr = @cr
  def self.vr = @@vr
end
Keeper.set(n)
junk = Array.new(200) { |i| i.to_s * 4 }
GC.start
p $gr, KR, Keeper.cr, Keeper.vr, junk.size
p $gr.to_a.size, KR.end, Keeper.cr.begin, Keeper.vr.end
