# Time.local / mktime / gm / utc with a splat: the count is known only at run
# time, and ten arguments are Time#to_a's order (sec, min, hour, day, month,
# year, ...), as svg-graph steps a month with Time.local(*arr).
t = Time.local(2024, 1, 15, 10, 20, 30)
arr = t.to_a
arr[4] += 1
u = Time.local(*arr)
p [u.year, u.month, u.day, u.hour, u.min, u.sec, u.utc?]
v = Time.mktime(*arr)
p [v.year, v.month, v.day, v.hour, v.min, v.sec]
g = Time.gm(*Time.utc(2023, 12, 31, 23, 59, 58).to_a)
p [g.year, g.month, g.day, g.hour, g.min, g.sec, g.utc?]
w = Time.utc(*[30, 20, 10, 15, 3, 2022, 0, 0, false, "UTC"])
p [w.year, w.month, w.day, w.hour, w.min, w.sec]
parts = [2021, 6]
x = Time.local(*parts, 7, 8)
p [x.year, x.month, x.day, x.hour, x.min, x.sec]
y = Time.utc(*[2020, "feb", 3, 4, 5, 6.5])
p [y.year, y.month, y.day, y.hour, y.min, y.sec, y.usec]
z = Time.utc(*[2020, 1, 2, 3, 4, 5, 250])
p z.usec
q = Time.local(*[1999])
p [q.year, q.month, q.day, q.hour]
[[], [1] * 9, [1] * 11].each do |a|
  begin
    Time.local(*a)
  rescue ArgumentError => e
    puts e.message
  end
end

# fields read as CRuby reads them: a built String month, a String field as
# Integer(str, 10), a Float or Rational truncated, a boolean refused, and
# with eight arguments the seventh ignored along with the eighth
m = +"fe"
m << "b"
p Time.utc(*[2024, m, 3]).month
p Time.utc(*[" 20_24 ", "02", "3"]).day
p Time.utc(*[2024, 1.9, Rational(5, 2)]).day
p Time.utc(*[2024, 1, 1, 0, 0, 5.5, "UTC", 0]).subsec
b = [2024, 1, 1, 0]
b[3] = true if ARGV.empty?
begin
  Time.utc(*b)
rescue TypeError => e
  puts e.message
end
begin
  Time.utc(*["2024x"])
rescue ArgumentError => e
  puts e.message
end
