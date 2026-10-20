# Complex#coerce answers [other as a Complex, self] for a number or a
# Complex, typed or through an Array element, and raises TypeError naming
# the operand's class for anything else
def t(label)
  p yield
rescue TypeError => e
  puts "#{label}: #{e.message}"
end
c = Complex(2, 3)
b = [c, 1][0]
[2, 1.5, Complex(1, 1)].each_with_index do |x, k|
  t("typed #{k}") { c.coerce(x) }
  t("boxed #{k}") { b.coerce(x) }
end
["x", nil, :s, [1], true].each_with_index do |x, k|
  t("typed bad #{k}") { c.coerce(x) }
  t("boxed bad #{k}") { b.coerce(x) }
end
t("literal") { c.coerce(2) }
t("literal bad") { c.coerce("x") }
