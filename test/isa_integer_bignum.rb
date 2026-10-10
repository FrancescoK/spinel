# A Bignum is an Integer: `when Integer` on a boxed value takes its arm for a
# Bignum as for a small Integer, and the arm reads the Bignum itself.
big = 9_999_999_999_999_999_999_999
vals = [2**100, -(2**100), big, -big, 7, -7, :pad, "s"]

vals.each do |v|
  case v
  when Integer then p [:when_int, v, v.abs, v + 1]
  when Symbol then p [:sym, v]
  else p [:else, v]
  end
end
