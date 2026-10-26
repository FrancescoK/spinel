# spinel: int64 -- assumes a 64-bit Integer (values or arithmetic past 2^31); not run on a 32-bit target
# Under --int-overflow=promote, String#hex and String#oct read a value past
# the machine word as a Bignum, as CRuby does and as #to_i already did; they
# raised RangeError. The default raise mode keeps its RangeError.
h = "f" * 20
o = "7" * 30
p h.hex
p "0x#{h}".hex
p "-#{h}".hex
p "ffff_ffff_ffff_ffff_ffff".hex
p o.oct
p "-#{o}".oct
p "0o#{o}".oct
p "0x#{h}".oct
p "0b#{"1" * 70}".oct
p "0d#{"9" * 20}".oct
p "ff".hex, "0x1A".hex, "zz".hex, "-0x10".hex
p "777".oct, "0x1f".oct, "0b101".oct, "089".oct, "".oct, "0_7".oct
p h.hex + 1
p "7fffffffffffffff".hex, "8000000000000000".hex, "-8000000000000000".hex
