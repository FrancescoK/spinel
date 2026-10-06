# #minmax on a Range read out of a mixed slot is Range's own [min, max],
# read off the endpoints with max first as CRuby evaluates them, for every
# Range kind and both routes a boxed receiver takes (the face switch beside
# the Enumerable row, and the Ruby-implemented Enumerable#minmax). A Float
# Range answered [nil, nil] there, or its Float bits read as Integers when
# the arms answered arrays of different kinds; an open one answered
# [nil, nil] instead of raising. A typed Float Range raised the minimum's
# error where CRuby raises the maximum's. As a yielded block's value
# (t { x.minmax } with an Array in the slot too) the spliced Enumerable
# definition left no value, and the C did not build.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue StandardError => e
  puts "#{s}: #{e.class}: #{e.message}"
end

src = [(1.5..3.0), (...2.5), (1.5..), (3.0..1.0), (..3), (1..4), (5..1),
       ("a".."e"), ("a"..."e"), ("e".."a"), [3, 1, 2], { b: 1, a: 2 }, 7]
src.each do |x|
  next if x.is_a?(Integer)
  t("#{x.inspect} minmax") { x.minmax }
  t("#{x.inspect} minmax rev") { x.minmax { |a, b| b <=> a } } unless x.is_a?(Hash)
end

def pick(k)
  case k
  when 0 then 1..10
  when 1 then 1.0..2.0
  when 2 then "a".."e"
  when 3 then [3, 1, 2]
  else 5
  end
end
p pick(0).minmax
p pick(1).minmax
p pick(2).minmax
p pick(3).minmax

puts "-- typed"
t("fbl") { (...2.5).minmax }
t("fempty") { (3.0..1.0).minmax }
t("fx") { (1.5...3.0).minmax }
t("sendless") { ("a"..).minmax }
t("sx") { ("a"..."e").minmax }
