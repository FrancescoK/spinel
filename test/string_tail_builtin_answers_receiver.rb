# A method ending in a String builtin that answers its receiver
# (force_encoding, encode!, scrub!, a bang, bytesplice, `clear << x`)
# answers that String: the caller took the last handle the method had
# published, a block's `out << c`, so `out.force_encoding("UTF-8")` built
# from "widget" answered "t" (#10095).
def widget_copy(s)
  out = +""
  s.each_char { |c| out << c }
  out.force_encoding("UTF-8")
end
w = widget_copy("widget")
puts w
puts w.length

def build(s)
  out = +""
  s.each_char { |c| out << c }
  out
end
def m1(s) = (o = build(s); s.each_char { |c| o << "" }; o.force_encoding("UTF-8"))
def m2(s); out = +""; s.each_char { |c| out << c }; out.force_encoding("UTF-8"); end
def m3(s); out = +""; s.each_char { |c| out << c }; out.encode!("UTF-8"); end
def m4(s); out = +""; s.each_char { |c| out << c }; out.scrub!; end
def m5(s); out = +""; s.each_char { |c| out << c }; out.replace(out + "!"); end
def m6(s); out = +""; s.each_char { |c| out << c }; out.squeeze!; out; end
def m8(s); out = +""; s.each_char { |c| out << c }; out.setbyte(0, 87); out; end
def m9(s); out = +""; s.each_char { |c| out << c }; out.prepend(">"); end
def m10(s); out = +""; s.each_char { |c| out << c }; out.insert(0, "<"); end
def m11(s); out = +""; s.each_char { |c| out << c }; out.clear << "z"; end
def m12(s); out = +""; s.each_char { |c| out << c }; out.b.force_encoding("BINARY"); end
def m13(s); out = +""; s.each_char { |c| out << c }; out.bytesplice(0, 1, "W"); end
def m14(s); out = +""; s.each_char { |c| out << c }; out.upcase!; end
def m15(s); out = +""; s.each_char { |c| out << c }; out.tr!("w", "W"); end
w = m1("widget"); p [:m1, w]
w = m2("widget"); p [:m2, w]
w = m3("widget"); p [:m3, w]
w = m4("widget"); p [:m4, w]
w = m5("widget"); p [:m5, w]
w = m6("widget"); p [:m6, w]
w = m8("widget"); p [:m8, w]
w = m9("widget"); p [:m9, w]
w = m10("widget"); p [:m10, w]
w = m11("widget"); p [:m11, w]
w = m12("widget"); p [:m12, w]
w = m13("widget"); p [:m13, w]
w = m14("widget"); p [:m14, w]
w = m15("widget"); p [:m15, w]
