# each_slice and each_cons bind a row's elements to the block's parameters,
# and a parameter with no element is nil: past a short last row, past the
# row size, or where the element is nil itself. Such a parameter reads as
# nil (String(x) is "", `x * 2` raises), and one past the row size no longer
# reads the next row's element. Under --int-overflow=promote a boxed row
# binds a scalar parameter with its nil kept.

def t
  yield
rescue => e
  puts "#{e.class}: #{e.message}"
end

[1, 1, 1, [1][ARGV.size + 1], 1].each_slice(2) { |w, x| p [w, String(x)] }
[1, 2, 3].each_slice(2) { |w, x| t { p [1, x].sum } }
[1, 2, 3].each_slice(2) { |w, x| p [1, x].compact }
[1, 2, 3, 4].each_slice(2) { |a, b, c| p [a, b, c] }
[1, 2, 3].each_cons(2) { |a, b, c| p [a, b, c] }
[1.5, 2.5, 3.5].each_slice(2) { |a, b| t { p b * 2 } }
["a", "b", "c"].each_slice(2) { |a, b| p [a, b] }
n = [2][ARGV.size]
[4, 5, 6].each_slice(n) { |a, b| p [a, b, b.nil?] }
s = [1]
_, u = *s
[1, u, 1].each_slice(2) { |w, x| p [w, x, x.nil?] }
[1, 2, 3, 4].each_slice(2) { |a, b| p a + b }
