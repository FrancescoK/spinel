# polar on a number read out of a mixed Array answers [abs, arg] like a
# plain one; a value of another kind still has no polar.
p [12, :a][0].polar
p [2.5, :a][0].polar
p [-3, :a][0].polar
p [-2.5, :a][0].polar
p [3r / 4, :a][0].polar
p [Complex(3, 4), :a][0].polar
p [2**70, :a][0].polar
r, t = [12, :a][0].polar
p r + 1, t
begin
  [:a, 1][0].polar
rescue NoMethodError => e
  puts e.message
end
