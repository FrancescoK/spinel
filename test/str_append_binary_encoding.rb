# The encoding a String append leaves its receiver in, as CRuby's
# compatibility rule picks it: an ASCII-only receiver takes a binary
# operand's encoding when the operand has high bytes, an ASCII-only operand
# keeps the receiver's, and a binary ASCII-only receiver becomes UTF-8 when
# text with high bytes goes in.

def enc(s) = s.encoding.to_s

body = "\x89PNG\r\n".b
out = +"HTTP/1.1 200 OK\r\n"
out << "X-A: 1\r\n\r\n"
out << body
p enc(out)
p out.scan(/^x-a:/i).length
p out.bytesize

o = +"abc"; o << "xy".b; p enc(o)
o = +""; o << body; p enc(o)
o = +"\u00e9"; o << "xy".b; p enc(o)
o = "ab".b; o << "\u00e9"; p enc(o)
o = "ab".b; o << "cd"; p enc(o)

o = +"abc"; o.concat(body); p enc(o)
o = +"abc"; o.concat("x", body); p enc(o)
o = +"abc"; o << "x#{body}y"; p enc(o)
o = "ab".b; o << "x#{"\u00e9"}y"; p enc(o)
o = +"abc"; o += body; p enc(o)
p enc("abc" + body)
p enc("#{"abc"}#{body}")

parts = ["a", body, "b"]
o = +""; parts.each { |x| o << x }; p enc(o); p o.bytesize
