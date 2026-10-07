# A value read out of a mixed Array that has no #to_i -- true, false, a
# Symbol, an Array, a Hash, a Range -- raises NoMethodError for it, as in
# CRuby; to_i answered 1, 0 or the Symbol's id. The kinds that have one
# still convert.
xs = [true, false, :a, [1], {a: 1}, 1..2, "12", 2.5, nil, Time.at(5), Rational(7, 2), 3]
xs.each do |x|
  p x.to_i
rescue NoMethodError => e
  puts e.message
end
p [true, 1].map(&:to_i) rescue p $!.class
