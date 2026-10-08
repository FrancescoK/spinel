# Flag-only: the default build cannot share these boxed aliases.
# A boxed String conditional lifts each selected arm before another alias
# takes the box, including a sequence whose last String has no handle yet.
c = ARGV.empty?
s = +"s"
s << ""
@x = 0
@x = c ? (puts "fresh arm"; 123.to_s) : s
a = [@x, 0]
a[0] << "!"
p @x, a
@x = c ? s : (puts "untaken"; 456.to_s)
a = [@x, 0]
s << "?"
a[0] << "."
p @x, a, s
@x = unless c
  s
else
  puts "unless arm"
  789.to_s
end
h = {value: @x, zero: 0}
h[:value] << "!"
p @x, h[:value]
x = 0
b = [0, (x = c ? (puts "local arm"; 42.to_s) : s)]
b[1] << "!"
p x, b
$g = 0
$g = c ? (puts "global arm"; 456.to_s) : s
b = [0, $g]
b[1] << "!"
p $g, b
@x = if c
  puts "nested arm"
  c ? (puts "nested fresh"; 5.to_s) : s
else
  s
end
b = [@x, 0]
b[0] << "!"
p @x, b
@x = c ? (puts "frozen arm"; "frozen") : s
b = [@x, 0]
begin
  b[0] << "!"
rescue FrozenError
  puts "frozen"
end
p @x
# Both container kinds also keep the selected existing handle.
t = +"t"
a = [0, c ? s : t]
h = {zero: 0, value: (!c ? s : t)}
a[1] << "A"
h[:value] << "H"
p s, t, a[1], h[:value]
