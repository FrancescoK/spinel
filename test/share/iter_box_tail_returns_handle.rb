# A method whose last statement is an iterator given a block over a boxed
# local (`s.scan(re) { }`, `s.each_char { }`) answers the String in the
# box. A change through the variable the call's value is written to
# reaches that String, and the strings the block kept.
def scan_tail(acc)
  t = +"ab"
  s = [t, 1].first
  s.scan(/./) { |m| m << "!"; acc << m }
end
def chars_tail(acc, src)
  s = [src, 1].first
  s.each_char { |ch| acc << ch }
end

acc = []
r = scan_tail(acc)
r << "?"
p r, acc

src = +"xy"
acc2 = []
r2 = chars_tail(acc2, src)
r2 << "z"
p r2, src, acc2
