# Integer() and Float() of a Complex are its #to_i and #to_f: the real part
# when the imaginary part is an exact zero, else RangeError naming the value
# (nil with exception: false), typed or through an Array element
def t(label)
  p yield
rescue RangeError, TypeError => e
  puts "#{label}: #{e.class}: #{e.message}"
end
t("Integer") { Integer(Complex(2, 0)) }
t("Integer imag") { Integer(Complex(2, 1)) }
t("Integer float re") { Integer(Complex(2.5, 0)) }
t("Float") { Float(Complex(2, 0)) }
t("Float imag") { Float(Complex(2, 1)) }
t("Float 0.0 imag") { Float(Complex(2, 0.0)) }
a = [Complex(2, 0), Complex(2, 1), 1]
t("boxed Integer") { Integer(a[0]) }
t("boxed Integer imag") { Integer(a[1]) }
t("boxed Float") { Float(a[0]) }
t("boxed Float imag") { Float(a[1]) }
t("lenient Integer") { Integer(Complex(2, 0), exception: false) }
t("lenient Integer imag") { Integer(Complex(2, 1), exception: false) }
t("lenient Float") { Float(Complex(2, 0), exception: false) }
t("lenient Float 0.0 imag") { Float(Complex(2, 0.0), exception: false) }
t("lenient boxed Integer") { Integer(a[0], exception: false) }
t("lenient boxed Float imag") { Float(a[1], exception: false) }
