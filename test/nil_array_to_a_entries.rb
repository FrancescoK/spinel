# Array#to_a and #entries on a receiver that may be nil (#9347). nil.to_a is
# [] (NilClass#to_a) and nil has no #entries, so the call stays a call:
# `x.to_a` on a nil slot answers [], not nil, and `x.entries` raises
# NoMethodError, where both were folded to the receiver itself. A non-nil
# Array's to_a answers the Array, and #entries (Enumerable's) a copy.
def raises
  yield
  puts "answered"
rescue NoMethodError
  puts "NoMethodError"
end

# an instance variable a write leaves nil, for each Array kind
class W
  def initialize(f)
    @i = f ? [1, 2] : nil
    @f = f ? [1.5, 2.5] : nil
    @s = f ? ["a", "b"] : nil
    @m = f ? [1, "a"] : nil
    @h = f ? {"k" => 1} : nil
  end
  def i_to_a = @i.to_a
  def f_to_a = @f.to_a
  def s_to_a = @s.to_a
  def m_to_a = @m.to_a
  def h_to_a = @h.to_a
  def i_entries = @i.entries
  def f_entries = @f.entries
  def s_entries = @s.entries
  def m_entries = @m.entries
  def h_entries = @h.entries
  def i_dup = @i.dup
  def s_clone = @s.clone
  def h_dup = @h.dup
end
n = W.new(false)
p n.i_to_a, n.f_to_a, n.s_to_a, n.m_to_a, n.h_to_a
raises { n.i_entries }
raises { n.f_entries }
raises { n.s_entries }
raises { n.m_entries }
raises { n.h_entries }
p n.i_dup, n.s_clone, n.h_dup
w = W.new(true)
p w.i_to_a, w.f_to_a, w.s_to_a, w.m_to_a, w.h_to_a
p w.i_entries, w.f_entries, w.s_entries, w.m_entries, w.h_entries
p w.i_dup, w.s_clone, w.h_dup

# an instance variable only another method fills
class U
  def fill = (@a = [3, 4])
  def to = @a.to_a
  def ent = @a.entries
end
u = U.new
p u.to
raises { u.ent }
u.fill
p u.to, u.ent

# a local a branch may leave nil
def local(f)
  a = [1, 2] if f
  s = ["x"] if f
  p a.to_a, s.to_a
  raises { a.entries }
  raises { s.entries }
end
local(false)
local(true)

# a parameter that may be nil
def param(a) = a.to_a
def param_entries(a) = a.entries
p param([1]), param(nil)
raises { param_entries(nil) }
p param_entries([2])

# to_a answers the Array itself, entries a copy
a = [1, 2]
b = a.to_a
b << 3
p a
c = a.entries
c << 4
p a, c
