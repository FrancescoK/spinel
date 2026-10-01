# A Time's year is written at least four digits wide, with the sign outside
# the padding, wherever it is formatted: iso8601/xmlschema (with and without
# fraction digits), to_s/inspect (unboxed and boxed), and the strftime
# directives that contain a year. C's %Y does not do that on glibc ("12")
# and pads a negative year inside the sign on macOS ("-012").
[12, -12, 0, 999, 1000, 2024, 10000, -10000].each do |y|
  t = Time.utc(y, 4, 12, 1, 2, 3)
  puts [t.iso8601, t.xmlschema, t.iso8601(3), t.xmlschema(1), t.to_s, t.inspect].join("  ")
  puts t.strftime("%Y|%F|%C|%y|%x|%D|%c|%v|%G|%g|%10Y|%-y|%^c")
  o = Time.new(y, 4, 12, 1, 2, 3, "+05:30")
  puts [o.iso8601, o.xmlschema(2), o.to_s, o.inspect, o.strftime("%F %c")].join("  ")
end

# the ISO week-based year differs from the calendar year around January 1
[[2021, 1, 1], [2024, 12, 30], [12, 1, 1]].each do |y, m, d|
  puts Time.utc(y, m, d).strftime("%Y %G %g %V")
end

# a boxed Time renders as an unboxed one does, offset included
box = [Time.utc(12, 4, 12, 1, 2, 3), Time.new(2024, 4, 12, 1, 2, 3, "+05:30"), 1, "s"]
p box[0]
p box[1]
puts box[0].to_s
puts box[1].to_s
p({ t: Time.utc(-12, 4, 12), n: 1 })

# a width counts the sign, `_` pads with spaces and `-` not at all
%w[%-Y %_Y %_10Y %-10Y %5Y %3Y %-G %_G %-C %_y %-y %^v %-F].each do |f|
  puts "#{f.ljust(6)} " + [12, -12, 2024].map { |y| Time.utc(y, 1, 5).strftime(f) }.join("|")
end

# a width wider than any year still pads the whole field, sign first
%w[%200Y %_200Y %200G %-200Y %010Y].each do |f|
  r = [12, -12, 2024].map { |y| Time.utc(y, 1, 5).strftime(f) }
  puts "#{f} #{r.map(&:size).inspect} #{r.map(&:strip).join("|")}"
end
puts Time.at(-5).utc.strftime("%10s|%_10s")
