# A String read out of an Array whose Strings are shared, at the tail of a
# parenthesized sequence, a begin body or a conditional arm (an arm left out
# answers nil), stored into an Integer Array, widens it as the String would
s = +"src"
a = [1, 2]
a[1] = (r = []; [s, 12].each { |x| r << x.to_s }; r[1])
s << "!"
p a
b = [1, 2]
b[0] = begin; q = []; [s, 12].each { |x| q << x.to_s }; q[1]; end
s << "?"
p b
c = [1, 2]
c << ((n = 3); (m = []; [s, 12].each { |x| m << x.to_s }; (m[1])))
p c
d = [1, 2]
f = ARGV.empty?
d[1] = f ? (t = []; [s, 13].each { |x| t << x.to_s }; t[1]) : "z"
p d
h = {"k" => 1}
h["j"] = (u = []; [s, 14].each { |x| u << x.to_s }; u[1])
p h
e = [1, 2]
e.insert(0, (v = []; [s, 15].each { |x| v << x.to_s }; v[1]))
p e
g = [1, 2]
g[1] = (w = []; [s, 16].each { |x| w << x.to_s }; w[1]) if f
p g
i = [1, 2]
i[1] = (z = [s, 17].map { |x| x.to_s }; z[1] if f)
p i
j = [1, 2]
j[1] = f ? [s, 18].map { |x| x.to_s }[1] : nil
p j
k = [1, 2]
k[1] = begin; y = [s, 19].map { |x| x.to_s }; y[1]; end unless f
p k
m = [1, 2]
m[0] = f ? (o = [s, 21].map { |x| x.to_s }; o[0] + "x") : o[1]
p m

# more arms than the walk's first buffer holds, the shared read in the last
rr = [s, 22].map { |x| x.to_s }
n9 = [1, 2]
n9[1] = case ARGV.size + 99
when 0 then "l0"
when 1 then "l1"
when 2 then "l2"
when 3 then "l3"
when 4 then "l4"
when 5 then "l5"
when 6 then "l6"
when 7 then "l7"
when 8 then "l8"
when 9 then "l9"
when 10 then "l10"
else rr[1]
end
p n9
u9 = [1, 2]
u9[1] = if ARGV.size == 5 then "e0"
elsif ARGV.size == 6 then "e6"
elsif ARGV.size == 7 then "e7"
elsif ARGV.size == 8 then "e8"
elsif ARGV.size == 9 then "e9"
elsif ARGV.size == 10 then "e10"
elsif ARGV.size == 11 then "e11"
elsif ARGV.size == 12 then "e12"
elsif ARGV.size == 13 then "e13"
elsif ARGV.size == 14 then "e14"
elsif ARGV.size == 15 then "e15"
else rr[1]
end
p u9
