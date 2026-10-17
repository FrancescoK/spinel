# A nil receiver that reaches a runtime function raises NoMethodError as
# CRuby does (#9347): the Array, Hash and String functions tested their
# receiver for NULL and answered a default (`push` pushed nothing, `include?`
# answered false, `delete` answered nil), where CRuby has no such method on
# nil. The slots below are never written nil, only left unset, so the
# compiler tests none of the calls and the raise comes from the runtime.
def raises(label)
  yield
  puts "#{label}: answered"
rescue NoMethodError
  puts "#{label}: NoMethodError"
end

# a typed Integer Array
class IA
  def setup = (@r = [3, 1, 2])
  def sort_bang = @r.sort!
  def incl = @r.include?(2)
  def compact_ = @r.compact
  def del = @r.delete(2)
  def ins = @r.insert(1, 9)
  def rot = @r.rotate!
end
raises("IA sort!") { IA.new.sort_bang }
raises("IA include?") { IA.new.incl }
raises("IA compact") { IA.new.compact_ }
raises("IA delete") { IA.new.del }
raises("IA insert") { IA.new.ins }
raises("IA rotate!") { IA.new.rot }
ia = IA.new; ia.setup
p ia.sort_bang
p ia.incl
p ia.compact_
p ia.del
p ia.ins
p ia.rot

# a typed Float Array
class FA
  def setup = (@r = [2.5, 1.5])
  def sort_bang = @r.sort!
  def incl = @r.include?(2.5)
  def idx = @r.index(2.5)
  def comp = @r.compact
end
raises("FA sort!") { FA.new.sort_bang }
raises("FA include?") { FA.new.incl }
raises("FA index") { FA.new.idx }
raises("FA compact") { FA.new.comp }
fa = FA.new; fa.setup
p fa.sort_bang
p fa.incl
p fa.idx
p fa.comp

# a typed String Array
class SA
  def setup = (@r = ["b", "a"])
  def pop_ = @r.pop
  def shift_ = @r.shift
  def incl = @r.include?("a")
  def mn = @r.min
  def sort_bang = @r.sort!
end
raises("SA pop") { SA.new.pop_ }
raises("SA shift") { SA.new.shift_ }
raises("SA include?") { SA.new.incl }
raises("SA min") { SA.new.mn }
raises("SA sort!") { SA.new.sort_bang }
sa = SA.new; sa.setup
p sa.incl
p sa.mn
p sa.sort_bang
p sa.shift_
p sa.pop_

# a mixed Array
class PA
  def setup = (@r = [1, "a"])
  def push_ = @r.push(2)
  def shovel = (@r << 2)
  def at0 = @r[0]
  def pop_ = @r.pop
  def len = @r.length
  def rev = @r.reverse!
  def flat = @r.flatten
end
raises("PA push") { PA.new.push_ }
raises("PA <<") { PA.new.shovel }
raises("PA []") { PA.new.at0 }
raises("PA pop") { PA.new.pop_ }
raises("PA length") { PA.new.len }
raises("PA reverse!") { PA.new.rev }
raises("PA flatten") { PA.new.flat }
pa = PA.new; pa.setup
p pa.push_
p pa.shovel
p pa.at0
p pa.pop_
p pa.len
p pa.rev
p pa.flat

# Hashes
class HI
  def setup = (@h = {"a" => 1})
  def get = @h["a"]
  def clr = @h.clear
  def hv = @h.value?(1)
  def rep = @h.replace({"b" => 2})
end
raises("HI []") { HI.new.get }
raises("HI clear") { HI.new.clr }
raises("HI value?") { HI.new.hv }
raises("HI replace") { HI.new.rep }
hi = HI.new; hi.setup
p hi.get
p hi.hv
p hi.rep
p hi.clr

# Strings
class ST
  def setup = (@s = "abca")
  def del = @s.delete("a")
  def sq = @s.squeeze
  def oct_ = @s.oct
  def lns = @s.lines(",")
end
raises("ST delete") { ST.new.del }
raises("ST squeeze") { ST.new.sq }
raises("ST oct") { ST.new.oct_ }
raises("ST lines") { ST.new.lns }
st = ST.new; st.setup
p st.del
p st.sq
p st.oct_
p st.lns

# a mutable String buffer
class SB
  def setup = (@b = +"")
  def cat = (3.times { |i| @b << i.to_s }; nil)
  def out = @b.dup
end
raises("SB <<") { SB.new.cat }
sb = SB.new; sb.setup; sb.cat
p sb.out
