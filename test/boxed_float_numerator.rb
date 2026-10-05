# spinel: int64
# numerator and denominator on a Float read out of a mixed Array answer as
# a plain Float does (the value itself and 1 for a non-finite one).
p [2.5, :a][0].numerator
p [2.5, :a][0].denominator
p [0.1, :a][0].denominator
p [-0.75, :a][0].numerator
p [Float::INFINITY, :a][0].numerator
p [Float::INFINITY, :a][0].denominator
p [Float::NAN, :a][0].denominator
p [3, :a][0].numerator
p [3r / 4, :a][0].denominator
p [2.5, :a][0].numerator + 1
begin
  [:a, 1][0].numerator
rescue NoMethodError => e
  puts e.message
end
