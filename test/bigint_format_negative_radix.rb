# spinel: int64
# A negative Bignum in %b, %o or %x with no sign flag prints its two's
# complement, as a Fixnum does: ".." and then the digit that repeats to the
# left. A sign flag (+ or space) prints the magnitude after a minus.
big = -(3 << 62)
wide = -(2**70 + 5)
p "%o" % big
p "%x" % wide
p "%b" % -(2**64)
p big.to_s(8)
p format("%o", big)
p format("%x", wide)
p format("%X", wide)
p format("%#x", wide)
p format("%#o", big)
p format("%#b", -(2**64))
p format("%+x", wide)
p format("% b", -(2**64))
p format("%30x|", wide)
p format("%-30x|", wide)
p format("%030x|", wide)
p format("%.30x|", wide)
p format("%x", 2**70 + 5)
p format("%x", -(2**64 - 1))
p format("%o", -(2**63 + 1))
p "%x" % [wide]
