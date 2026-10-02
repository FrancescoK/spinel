# A boxed Enumerator returns its source's each result and rejects index writes.
e = [3.5, 1.5].each
e = 5 if ARGV.size > 3
p e.each { |q| p q }
p e.each { |q| q }
begin
  e[3] = 1.5
rescue NoMethodError
  puts 'NoMethodError'
end
c = e.each { |q| q }
c[3] = 9.5
p c
p e.each { |q| break :stopped }
p e.each { |q| break :missed if q == 99 }
g = Enumerator.new do |y|
  y << 7
  y << 8
  :finished
end
g = nil if ARGV.size > 3
p g.each { |q| p q }
p g.each { |q| q }
p g.next
p g.each { |q| q }
p g.next
a = [1, 2]
a = nil if ARGV.size > 3
p a.each { |q| q }
h = {a: 1}
h = nil if ARGV.size > 3
p h.each { |q| q }
