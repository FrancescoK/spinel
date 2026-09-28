# inject(:+) over a String Array holding nil raises what String#+ raises, as
# CRuby does, where it joined the nil as "".
a = (1..3).map { |i| "n#{i}" }
a[5] = "end"
p (a.inject(:+) rescue [$!.class, $!.message])
p (a.reduce("x", :+) rescue [$!.class, $!.message])
b = (1..2).map { |i| "m#{i}" }
b[3] = "z"
b[0] = nil
p (b.inject(:+) rescue [$!.class, $!.message])
# a String Array whose first element is nil: the accumulator starts as nil
x = ["x"]
x.clear
x[2] = "c"
p (x.inject(:+) rescue [$!.class, $!.message])
p a.first(3).inject(:+)
