# `next <v>` in a map over a receiver typed poly (an Array or a Hash the
# inference could not pin) contributes <v>, as it does over a typed Array.
# The step's `continue` skipped the push, so the element was dropped and
# the result came out shorter (#NNNN).
def items(x) = x ? [1, 2, 3] : {}
def pairs(x) = x ? { "a" => 1, "b" => 2, "c" => 3 } : [0]

a = items(true)
p a.map { |v| next v * 10 if v == 2; v }
p a.collect { |v| next v.to_s if v == 2; v }
p a.map { |v| next if v == 2; v }
p a.map { |v| next v * 10 }
p a.map { |v| if v == 2 then next v * 10 end; v + 1 }

# statements ahead of the next still run once per element
log = []
p a.map { |v| log << v; next -v if v.odd?; v }
p log

# a block local starts fresh on every element
p a.map { |v| seen = v if v == 1; next seen if v == 3; seen }

# a next inside an inner block leaves that block only
p a.map { |v| [5].each { |w| next w }; next 7 if v == 1; v }

# |k, v| over a poly Hash, the shape that dropped aws-eventstream's
# boolean headers: `next [..].join if !!pattern == pattern`
h = pairs(true)
p h.map { |k, v| next k * 3 if v == 2; k }
p h.map { |k, v| next [k, 0] if v == 1; [k, v] }.to_h

def table
  { "t" => [true, 0], "f" => [false, 1], "s" => [nil, 7] }
end
def headers(x) = x ? { "t" => "t", "f" => "f", "s" => "s" } : [0]
p(headers(true).map do |key, type|
  pattern, index = table[type]
  next [key, index.to_s].join if !!pattern == pattern
  [key, "=", index.to_s].join
end)

# a next leaves the step only: a rescue around the map still catches what is
# raised after it (the step's `continue` popped the rescue's frame)
def boom(r)
  raise TypeError, "after #{r.inspect}"
end
begin
  boom(a.map { |v| next 0 if v == 1; v })
rescue TypeError => e
  puts e.message
end
begin
  boom(a.map { |v| next if v == 1; v })
rescue TypeError => e
  puts e.message
end
puts "still running"
