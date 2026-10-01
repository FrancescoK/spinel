# With StringScanner reachable, a boxed String still answers String#scan:
# the dispatch's String arm runs the String shortcut, and the block form
# keeps its String path.
require "strscan"

def pick(f) = f ? StringScanner.new(+"ab12cd") : +"x9y88"

[true, false].each do |f|
  s = pick(f)
  p s.scan(/[a-z]+/)
  p s.scan(/\d+/)
end

v = [1, "a5b66", nil][1]
p v.scan(/\d+/)
v.scan(/\d+/) { |m| p m }
w = [1, "k(a)k(b)", nil][1]
p w.scan(/k\((.)\)/)
