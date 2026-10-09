# The share rows preserve initializers, missing-key defaults and thrown values.
s = +"throw"
r = catch(:tag) { throw :tag, s }
r << "!"
p s

s = +"memo"
r = (1..2).each_with_object(s) { |i, memo| memo << i.to_s }
r << "!"
p s

s = +"missing"
h = {"present" => +"value"}
r = h.delete("absent") { |key| s }
r << "!"
p s

s = +"copy"
a = [s]
b = Array.new(a)
b[0] << "!"
p [s, a, b]
