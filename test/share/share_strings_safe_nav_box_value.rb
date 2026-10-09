# spinel: share
# spinel: gc-minor
# `s&.to_s` where a box is expected (a method's answer, an Array element, a
# Hash value, an `equal?` operand): a String is its own box, and nil stays
# nil rather than becoming "".
def conv(s) = s&.to_s
csrc = +"abc"
cb = conv(csrc)
cb << "1"
p csrc, conv(nil)
def id_ret(s) = s&.to_s.equal?(s)
p id_ret(csrc), id_ret(nil), id_ret(1)
cs = ARGV.size > 5 ? nil : csrc
cn = ARGV.size > 5 ? csrc : nil
ca = [cs&.to_s, 1]
ca[0] << "2"
p csrc, ca
ch = {k: cs&.to_s}
ch[:k] << "3"
p csrc, ch
p [cn&.to_s, 1], {k: cn&.to_s}
cm = ARGV.size > 5 ? +"m" : nil
p cm&.to_s.equal?(nil), cm&.to_s.nil?
