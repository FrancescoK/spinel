# A Bignum is an Integer: an is_a?(Integer) / kind_of?(Integer) guard and a
# `when Integer` hold for it, and the value read under the guard is the
# Bignum itself, with its arithmetic, as for a small Integer.
big = 9_999_999_999_999_999_999_999
vals = [2**100, -(2**100), big, -big, 7, -7, :pad, "s"]

vals.each do |v|
  next unless v.is_a?(Integer)
  p [v, v + 1, v * 2]
end

vals.each do |v|
  if v.kind_of?(Integer)
    p [:int, v - 1]
  else
    p [:other, v]
  end
end

vals.each do |v|
  case v
  when Integer then p [:when_int, v, v.abs]
  when Symbol then p [:sym, v]
  else p [:else, v]
  end
end
