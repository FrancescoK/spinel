# Numeric#i through an Array element answers 0+vi as the typed receiver
# does; a Complex, a String or nil has no #i
def t(label)
  p yield
rescue NoMethodError => e
  puts "#{label}: #{e.message}"
end
a = [42, 2.5, -3, -1.5, Complex(1, 2), "x", nil]
a.each_with_index { |v, k| t("i #{k}") { v.i } }
p(a[0].i + 1)
p a[1].i.imaginary
