# A nil receiver raises NoMethodError under the name the call was written
# with, as CRuby does (#9347): `@r.size` is "undefined method 'size' for nil",
# where the runtime function the compiler shares among the spellings of one
# method (size and count read the length; at, first, last and dig read an
# element; << and append push) could only say length, [] and push. The slots
# below are filled by `setup`, which the nil calls never reach, so the
# compiler tests none of them. Each name is checked on a mixed Array and an
# Array of objects, then the same calls are made on a filled slot, where they
# answer as before.
def raises(label)
  yield
  puts "#{label}: answered"
rescue NoMethodError => e
  puts "#{label}: #{e.message}"
end

class Item
  def initialize(n) = (@n = n)
  attr_reader :n
end

# a mixed Array
class PA
  def setup = (@r = [1, "a", :b])
  def length_ = @r.length
  def size_ = @r.size
  def count_ = @r.count
  def empty_ = @r.empty?
  def first_ = @r.first
  def last_ = @r.last
  def at_ = @r.at(1)
  def idx = @r[0]
  def dig_ = @r.dig(0)
  def dig_two = @r.dig(0, 1)
  def shl = (@r << 4)
  def shl_val = (x = (@r << 4); x.class)
  def append_ = @r.append(4)
  def append_two = @r.append(4, 5)
  def push_ = @r.push(4)
  def push_two = @r.push(4, 5)
end
%i[length_ size_ count_ empty_ first_ last_ at_ idx dig_ dig_two shl shl_val append_ append_two push_ push_two].each do |m|
  raises("PA #{m}") { PA.new.public_send(m) }
end
pa = PA.new; pa.setup
p [pa.length_, pa.size_, pa.count_, pa.empty_, pa.first_, pa.last_, pa.at_, pa.idx, pa.dig_]
p pa.shl
p pa.append_two
p pa.push_

# an Array of objects
class OA
  def setup = (@r = [Item.new(1), Item.new(2)])
  def length_ = @r.length
  def size_ = @r.size
  def count_ = @r.count
  def empty_ = @r.empty?
  def first_ = @r.first
  def last_ = @r.last
  def at_ = @r.at(1)
  def idx = @r[0]
  def shl = (@r << Item.new(3))
  def append_ = @r.append(Item.new(3))
  def push_ = @r.push(Item.new(3), Item.new(4))
  def ns = @r.map(&:n)
end
%i[length_ size_ count_ empty_ first_ last_ at_ idx shl append_ push_].each do |m|
  raises("OA #{m}") { OA.new.public_send(m) }
end
oa = OA.new; oa.setup
p [oa.length_, oa.size_, oa.count_, oa.empty_, oa.first_.n, oa.last_.n, oa.at_.n, oa.idx.n]
oa.shl; oa.append_; oa.push_
p oa.ns

# a Hash
class HI
  def setup = (@h = {1 => 2, 3 => 4})
  def length_ = @h.length
  def size_ = @h.size
  def count_ = @h.count
  def empty_ = @h.empty?
  def value_ = @h.value?(2)
  def has_value_ = @h.has_value?(2)
end
%i[length_ size_ count_ empty_ value_ has_value_].each do |m|
  raises("HI #{m}") { HI.new.public_send(m) }
end
hi = HI.new; hi.setup
p [hi.length_, hi.size_, hi.count_, hi.empty_, hi.value_, hi.has_value_]

# a String
class ST
  def setup = (@s = +"abc")
  def length_ = @s.length
  def size_ = @s.size
  def dedup_ = @s.dedup
  def uminus = -@s
end
%i[length_ size_ dedup_ uminus].each do |m|
  raises("ST #{m}") { ST.new.public_send(m) }
end
st = ST.new; st.setup
p [st.length_, st.size_, st.dedup_, st.uminus]

# difference of a typed Array: one operand, several, and an operand of
# another element kind (boxed after the receiver has been tested)
class IA
  def setup = (@a = [1, 2, 3]; @b = [2]; @t = ["x"])
  def minus = @a - @b
  def diff = @a.difference(@b)
  def diff_two = @a.difference([2], [3])
  def diff_float = @a.difference([1.5])
  def diff_str = @t.difference([1])
  def diff_mixed = @a.difference([1, "x"])
end
%i[minus diff diff_two diff_float diff_str diff_mixed].each { |m| raises("IA #{m}") { IA.new.public_send(m) } }
ia = IA.new; ia.setup
p [ia.minus, ia.diff, ia.diff_two, ia.diff_float, ia.diff_str, ia.diff_mixed]

# the length of a Hash of any kind, and first, last and at read off a call's
# result or a boxed parameter (the call is rewritten to a [] read)
class HK
  def setup = (@s = {"a" => 1}; @x = {1 => "x"}; @y = {a: 1.5}; @z = {1 => [1]})
  def s_len = @s.length
  def s_size = @s.size
  def s_count = @s.count
  def s_empty = @s.empty?
  def x_len = @x.length
  def y_len = @y.length
  def z_len = @z.length
end
%i[s_len s_size s_count s_empty x_len y_len z_len].each { |m| raises("HK #{m}") { HK.new.public_send(m) } }
hk = HK.new; hk.setup
p [hk.s_len, hk.s_size, hk.s_count, hk.s_empty, hk.x_len, hk.y_len, hk.z_len]

class MK
  def initialize(f) = (@f = f)
  def mk = @f ? [1, "a", 2.5] : nil
end
raises("MK first of a call") { MK.new(false).mk.first }
raises("MK last of a call") { MK.new(false).mk.last }
raises("MK at of a call") { MK.new(false).mk.at(0) }
p [MK.new(true).mk.first, MK.new(true).mk.last, MK.new(true).mk.at(1)]
def lst(a) = a.last
def fst(a) = a.first
def at0(a) = a.at(0)
pa = [1, "a"]
raises("boxed last") { lst(nil) }
raises("boxed first") { fst(nil) }
raises("boxed at") { at0(nil) }
p [lst(pa), fst(pa), at0(pa)]
