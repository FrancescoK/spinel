# Range#min and #max with no block answer as CRuby's range_min / range_max
# do, for a Range typed as itself and for one read out of a mixed slot:
# an empty range (its begin past its end, or at it with the end excluded)
# is nil, an open side raises RangeError, and a String Range with its end
# excluded walks its members. A Float Range answered its begin and end
# when empty; a String Range answered its endpoints in every case, nil
# for an open side; a boxed Integer Range materialized itself first, so an
# endless one said it could not convert to an array.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue StandardError => e
  puts "#{s}: #{e.class}: #{e.message}"
end

puts "-- Float"
t("empty min") { (3.0..1.0).min }
t("empty max") { (3.0..1.0).max }
t("point excl min") { (1.0...1.0).min }
t("point excl max") { (1.0...1.0).max }
t("empty excl max") { (3.0...1.0).max }
t("excl max") { (1.0...2.0).max }
t("min") { (1.0..2.0).min }
t("max") { (1.0..2.0).max }

puts "-- String"
t("min") { ("a".."e").min }
t("max") { ("a".."e").max }
t("excl min") { ("a"..."e").min }
t("excl max") { ("a"..."e").max }
t("empty min") { ("e".."a").min }
t("empty max") { ("e".."a").max }
t("point excl min") { ("a"..."a").min }
t("point excl max") { ("a"..."a").max }
t("beginless max") { (.."e").max }
t("beginless min") { (.."e").min }
t("endless min") { ("a"..).min }
t("endless max") { ("a"..).max }
t("longer end max") { ("a".."zz").max }
t("shorter end min") { ("y".."ab").min }

puts "-- boxed"
src = [(3.0..1.0), (1.0...1.0), ("e".."a"), ("a"..."e"), (.."e"), ("a"..),
       (1..), (..3), (5..1), (1...1), (1..4), 0]
src.each do |x|
  next if x == 0
  t("#{x.inspect} min") { x.min }
  t("#{x.inspect} max") { x.max }
end
