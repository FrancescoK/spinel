# Complex(String) and String#to_c read each number by Ruby's syntax: no
# "nan", "inf" or "Infinity", no hex, no trailing "."; Complex() raises for
# such a string, #to_c stops where the number ends
def t(s)
  p Complex(s)
rescue ArgumentError => e
  puts e.message
end
%w[nan NaN inf Infinity -Infinity 1+NaNi NaN+1i 1+Infinityi NaNi 0x10 0X1 1. 1.+2i 1+0x2i].each { |s| t(s) }
p "nan".to_c, "inf".to_c, "0x10".to_c, "1.".to_c, "1+0x2i".to_c
t(".5")
t("-.5")
t("1.5e-3i")
t("1+2i")
p "3-4i".to_c
# leading whitespace of any kind is skipped; none between the parts
["\n1", "\t1", " 1+2i", "\r\n2+3i", "1 2i", "1 +2i"].each { |s| t(s); p s.to_c }
t("5.e3")
t("1+5.i")
a = ["NaN", 1]
t(a[0])
p Complex("inf", exception: false)
