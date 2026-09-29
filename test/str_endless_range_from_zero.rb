# An endless inclusive range from 0 takes the whole string, as [0...] and
# [0..-1] do, whether the receiver is typed or boxed.
bits = "\x55".unpack1("B*")
zero = 0
p bits[0..], bits[zero..], bits[0...], bits[1..], bits[8..], bits[9..]
p bits[0..100], bits[-3..], bits[0..7], bits[0...8]
s = "héllo"
p s[0..], s[0..10], s[5..], s[6..]
p "abc"[zero..]
