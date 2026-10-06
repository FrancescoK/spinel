# Shapes beside the refused String keepers (a Hash.new block's value,
# Array.new(n, s), fetch/delete keys, a default block's key, zip/flatten/
# sum pairs, a user Enumerable, String(obj), StringIO and OpenStruct,
# Enumerator.new, a String mutator as a Method object, a lazy block that
# mutates): the String is frozen, fresh per read, never mutated in place,
# or not one the keeper hands out, so each compiles and answers as CRuby.
require "stringio"
require "ostruct"
s1 = +"abc"; a1 = Array.new(2, s1); p a1[0].upcase, s1
s2 = "abc"; a2 = Array.new(2, s2); p a2
s3 = +"abc"; h3 = Hash.new { |hh3, k3| s3 }; p h3[:x], s3
h4 = Hash.new { |hh4, k4| +"d" }; r4 = h4[:x]; r4 << "!"; p r4
s5 = +"abc"; h5 = Hash.new(s5); r5 = h5[:missing]; r5 << "!"; p s5, r5
s6 = +"abc"; h6 = Hash.new { |hh6, k6| hh6[k6] = s6 }; h6[:x]; r6 = h6[:x]; r6 << "!"; p s6, r6
s7 = +"abc"; io7 = StringIO.new(s7); p io7.string
io8 = StringIO.new(+""); io8 << "x"; p io8.string
s9 = +"abc"; p s9.method(:upcase).call, s9.method(:size).call
p [+"a"].lazy.map { |x10| x10.upcase }.first
s11 = +"abc"; r11 = [1].zip([s11])[0][1]; p r11.upcase, s11
s12 = +"abc"; e12 = Enumerator.new { |y12| y12 << s12 }; p e12.next, s12
s13 = +"a"; o13 = OpenStruct.new(n: s13); p o13.n, s13
s14 = +"abc"; p({}.fetch(s14) { |k14| k14.upcase }, s14)
