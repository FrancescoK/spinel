# Hash.new(capacity: n) with a value computed from locals, an instance
# variable or a collection's size: the keyword only sizes the table, so the
# Hash has no default (it was taken for the default, {capacity: n}).
items = [1, 2, 3]
p Hash.new(capacity: items.size)[:x]
h = Hash.new(capacity: items.size * 2)
h[:a] = 1
p h
p Hash.new(capacity: (items.length + 2))[:x]
s = "abc"
p Hash.new(7, capacity: s.size)[:x]
@n = 4
p Hash.new(capacity: @n)[:x]
def mk(n) = Hash.new(capacity: n + 1)
p mk(3)[:q]
[1, 2].each { |i| g = Hash.new(capacity: i * 10); g[i] = i; p g }
p Hash.new(capacity: items.size) { |hh, k| k.to_s * 2 }[:ab]

# A capacity from a method call still runs (after a default), once, and
# must convert to an Integer; the Hash has no default from it.
$calls = 0
def cap(k)
  $calls += 1
  puts "cap #{k.inspect}"
  k
end
def dflt
  puts "dflt"
  0
end
h = Hash.new(capacity: cap(1))
h[:a] = 1
p h, h[:b]
p Hash.new(capacity: cap(2))[:x]
p Hash.new(dflt, capacity: cap(3))[:x]
p Hash.new(capacity: cap(4)) { |hh, k| k.to_s * 2 }[:ab]
@iv = Hash.new(capacity: cap(5))
p @iv
$gv = Hash.new(capacity: cap(6))
$gv[1] = 2
p $gv
def made(k) = Hash.new(capacity: cap(k))
m = made(7)
m["s"] = 1.5
p m
p Hash.new(capacity: cap(8.5))[:y]
Hash.new(capacity: cap(9))
[nil, "x", :s].each do |v|
  begin
    Hash.new(capacity: cap(v))
    p :no_error
  rescue TypeError => e
    p e.message
  end
end
p $calls
