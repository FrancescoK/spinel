# `s << "...#{n}..."` appends an Integer part's digits straight from a stack
# buffer instead of building a String for each one: positive, negative and
# zero parts, a nil part (it appends nothing), parts beside a String part,
# into a String builder, a String local and a binary String, and into a
# frozen String (FrozenError, as for any append).
out = +"<"
room = 7
[1, -22, 0, 333].each { |i| out << "<t #{room}:#{i}>#{i * 1000}#{-i}</t>" }
x = [4, nil].first
y = [nil, 4].first
out << "a#{x}b"
out << "c#{y}d"
out << "#{y}"
w = "w"
out << "#{w}#{room}#{w}"
puts out
s = String.new("lit")
s += "#{room}"
s << "#{room}!#{x}"
puts s
b = "\xff".b + ""
b << "#{room}-#{x}"
p b, b.encoding, b.bytesize
f = +"frozen"
f.freeze
begin
  f << "#{room}"
rescue FrozenError => e
  puts e.class
end
n = 0
acc = +""
while n < 2000
  acc << "#{n},"
  n += 1
end
puts acc.bytesize, acc[-12..]
