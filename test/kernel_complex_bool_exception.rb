# Kernel#Complex of a Boolean under `exception:`: false as the flag answers
# nil, true raises the TypeError a plain call raises, and a flag that is not
# a Boolean is an ArgumentError. A boxed Boolean answers the same.
def t(label)
  r = yield
  puts "#{label} => #{r.inspect}"
rescue => e
  puts "#{label} => #{e.class}: #{e.message}"
end
b = [true, 1][0]
f = [false, 1][0]
flag = [false, 1][0]
t("false, false") { Complex(false, exception: false) }
t("true, false") { Complex(true, exception: false) }
t("true, true") { Complex(true, exception: true) }
t("false, true") { Complex(false, exception: true) }
t("true, nil") { Complex(true, exception: nil) }
t("true, flag") { Complex(true, exception: flag) }
t("boxed true, false") { Complex(b, exception: false) }
t("boxed false, true") { Complex(f, exception: true) }
t("boxed true, nil") { Complex(b, exception: nil) }
t("boxed 1, false") { Complex([1, "x"][0], exception: false) }
t("false") { Complex(false) }
t("order") { Complex((puts "operand"; true), exception: (puts "flag"; false)) }
