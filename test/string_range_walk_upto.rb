# A String range and String#upto walk the members CRuby's
# rb_str_upto_each yields: every byte between two one-character ends,
# zero-padded numbers between two all-digit ends, and otherwise succ
# steps that stop past the end's length, with no cap on the count.
p ("a".."bb").to_a.size, ("a".."bb").to_a.last(3)
p ("A".."c").to_a.size, ("A".."c").to_a[25, 4]
p ("Y".."b").to_a
p ("A"..."c").to_a.last
p ("a".."aa").to_a.size
p ("1".."010").to_a
p ("9".."11").to_a, ("08".."11").to_a, ("1"..."3").to_a
p ("aa".."z").to_a, ("b".."a").to_a, ("a"..."a").to_a
p ("a".."zzz").to_a.size, ("a".."zzz").count
p ("a".."bb").map(&:upcase).last
r = []
"a".upto("bb") { |s| r << s }
p r.size, r.first(3), r.last(3)
q = []
"A".upto("c") { |s| q << s }
p q.size, q[25, 4]
"1".upto("010") { |s| print s, " " }
puts
"x".upto("zz") do |s|
  break if s == "ab"
  print s, ","
end
puts
n = 0
("a".."bb").each { |s| n += 1 }
p n
