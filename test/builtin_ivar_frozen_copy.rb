# An ivar on a builtin value follows CRuby through dup, clone and freeze:
# dup and clone copy the ivars (clone keeps the frozen state, dup does not),
# a write to a frozen value raises FrozenError naming it, and an immediate
# or a Range -- frozen always -- reads nil and raises on a write.
# spinel: gc-minor
class Array
  def tag = @tag
  def tag=(v)
    @tag = v
  end
end

class Hash
  attr_accessor :label
end

class Random
  def note = @note
  def note!(v) = (@note = v)
end

class Integer
  def mark = @mark
  def mark!(v) = (@mark = v)
end

class Symbol
  def mark = (@mark ||= 1)
end

class Range
  def mark!(v) = (@m = v)
end

def try
  yield
rescue => e
  "#{e.class}: #{e.message}"
end

a = [1, 2]
a.tag = :x
b = a.dup
c = a.clone
p b.tag, c.tag, b.instance_variables
b.tag = :changed
p a.tag, b.tag
a.freeze
d = a.clone
e = a.dup
p d.frozen?, d.tag, e.frozen?, e.tag
p try { a.tag = 3 }
p try { d.tag = 3 }
e.tag = :thawed
p e.tag, a.tag

h = {k: 1}
h.label = "L"
p h.dup.label, h.clone.label
h.freeze
p try { h.label = "M" }, h.label

r = Random.new(5)
r.note!(9)
p r.dup.note, r.clone.note, r.instance_variables
r.freeze
p try { r.note!(1) }.sub(/0x\h+/, "0x"), r.note

p 5.mark, try { 5.mark!(1) }, try { 5.instance_variable_set(:@mark, 2) }
p try { :sym.mark }
p try { (1..2).mark!(3) }
p try { nil.instance_variable_set(:@a, 1) }
p [1, 2].frozen?, [3].tag
