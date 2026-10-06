# finite? and infinite? on a Complex read out of a mixed Array: finite?
# when both parts are, infinite? 1 when either part is infinite.
p [Complex(3, 4), :a][0].finite?
p [Complex(3, 4), :a][0].infinite?
p [Complex(1, Float::INFINITY), :a][0].finite?
p [Complex(1, Float::INFINITY), :a][0].infinite?
p [Complex(-Float::INFINITY, 0), :a][0].infinite?
p [Complex(Float::NAN, 1), :a][0].finite?
p [Complex(Float::NAN, 1), :a][0].infinite?
p [Complex(1.5, 2), :a][0].finite?
p [2.5, :a][0].finite?
p [-Float::INFINITY, :a][0].infinite?
begin
  [:a, 1][0].finite?
rescue NoMethodError => e
  puts e.message
end
