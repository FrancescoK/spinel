# String + String picks its encoding as CRuby does: an ASCII-only operand
# gives way to the other one, so an empty String.new (ASCII-8BIT) plus UTF-8
# text is UTF-8, and a binary String with high bytes stays binary.
t = String.new
t += "é"
p t.encoding, t
p ("abc".b + "é").encoding
p ("é" + "abc".b).encoding
p ("\xff".b + "abc").encoding
p ("abc".b + "x" + "é").encoding
p ("a".b + "b".b + "c").encoding
p (String.new + "é" + "a").encoding
