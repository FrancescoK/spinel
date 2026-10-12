# An if, unless or case before the tail of an Array.new block runs for its
# effect: when its condition is false its nil value is discarded, not read
# as an Integer.

bytes = Array.new(4) do |offset|
  byte = 0xff
  byte ^= 0xff if offset.odd?
  byte
end
p bytes

p Array.new(3) { |i| v = 1; v = 0 if i.odd?; v }
p Array.new(3) { |i| v = 1; if i.odd? then v += 1 end; v }
p Array.new(3) { |i| v = 1; unless i.odd? then v += 1 end; v }
p Array.new(3) { |i| v = 1; v += 5 unless i.even?; v }
p Array.new(3) { |i| v = 1; case i when 1 then v = 7 end; v }
p Array.new(3) { |i| v = 1; i.odd? ? (v = 0) : nil; v }
p Array.new(3) { |i| v = 1.5; v = 2.5 if i.odd?; v }
p Array.new(3) { |i| s = "a"; s = "b" if i.odd?; s }
