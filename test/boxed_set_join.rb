# Set#join joins the members, as CRuby's does, on a Set read out of a mixed
# Array as on a typed one; the boxed form had rendered the Set's inspect.
s = Set[3, 1, 2]
p s.join("-")
p s.join
xs = [s, "x", [4, 5]]
p xs[0].join("-")
p xs[0].join
p xs[2].join("+")
p Set[[1, 2], 3].join(",")
p Set[].join("-")
begin
  [nil, 1][0].join
rescue NoMethodError => e
  p e.message
end
