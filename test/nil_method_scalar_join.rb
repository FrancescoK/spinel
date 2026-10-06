# A method whose value is nil, joined with an Integer or Float answer into one
# scalar slot: the value can be nil, so nil's own methods (to_a, to_h, =~,
# and a Float's &, |, ^) answer as nil does. The nil came from a method the
# call dispatches to: one beside the value it is joined with (`c ? z : 1`),
# an override in a subclass, a class method, or a receiver that stays poly.

def z = nil
def g(i) = i == 0 ? z : 1
def gf(i) = i == 0 ? z : 1.5

x = ARGV.empty? ? z : 1
p x.to_a, x.to_h, x =~ /a/, x !~ /a/, x.nil?
p g(0).to_a, g(1).nil?, (g(1).to_a rescue :raised)
p gf(0).to_a, gf(0) & true, gf(0) | 1, gf(0) ^ nil, (gf(1).to_h rescue :raised)
h = {}
h[g(0)] = 1
p h, [g(0), g(1)], [g(0), g(1)].compact.sum

class C
  def initialize; @a = 1; end
  def bump = @a += 1
  def nop = nil
  def pick(i)
    case i
    when 0 then bump
    when 1 then nop
    end
  end
  def self.cz = nil
  def self.cpick(i) = i == 0 ? cz : 2
end
class D < C
  def nop = 7
end
class F < C
  def f = nil
end
class G < F
  def f = 2.5
end

c = C.new
p c.nop.to_a, c.nop.to_h, D.new.nop, (D.new.nop.to_a rescue :raised)
p c.pick(1).to_a, c.pick(2).to_h, c.pick(0), D.new.pick(1)
p C.cpick(0).to_a, C.cpick(1)
p F.new.f.to_a, F.new.f & 1, G.new.f
n = 0
10.times { |k| v = c.pick(k % 2); n += v if v }
p n

def mk(i) = i == 0 ? C.new : D.new
[0, 1].each do |i|
  o = mk(i)
  p((o.nop.to_a rescue :raised), o.nop.nil?, o.nop.class)
end
