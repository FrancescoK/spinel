# A blockless each_char, each_line, each_byte or each_codepoint on a String
# read out of a container (a boxed receiver) answers an Enumerator, as on a
# String variable: next, size, with_index and lazy work on it. It answered
# the Array chars, lines or bytes answers, which has no #next.

x = [+"ab", 1].first
e = x.each_char
p e.class, e.next, e.next, e.size
p e.with_index.to_a, e.map(&:upcase), e.to_a
l = x.each_byte.lazy.map { |b| b + 1 }
p l.to_a
p x.each_line.to_a, x.each_codepoint.next, x.each_byte.sum
y = [+"q\nr", 2].first
el = y.each_line
p el.next, el.size, el.to_a
p x.each_char.select { |c| c > "a" }, x.each_char.with_index.map { |c, i| c * (i + 1) }
begin
  [1, 2].first.each_char
rescue NoMethodError => ex
  p ex.class
end
