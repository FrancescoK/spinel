# spinel: not-cruby -- CRuby's Hash takes every key; a hash Spinel typed narrower raises instead of dropping the entry
def try(label)
  yield
rescue TypeError => e
  puts "#{label}: TypeError: #{e.message}"
end

class SK
  def initialize(f) = (@f = f)
  def to_hash = @f ? { "s" => 2 } : { x: 1 }
end

h = { a: 1 }
try("merge!") { h.merge!(SK.new(true)) }
p h
g = { a: 1 }
try("update") { g.update(SK.new(false), SK.new(true)) }
p g
w = { a: 1 }
x = [{ "s" => 2 }, 1][0]
try("boxed") { w.merge!(x) }
p w
v = { a: "v" }
try("value") { v.merge!(SK.new(true)) }
p v
