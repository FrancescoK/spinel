# force_encoding("ascii") makes a binary String text, so a high byte is the
# invalid character it is in US-ASCII (spinel has no US-ASCII tag of its own).
x = [0x80].pack("C")
p x.dup.force_encoding("ascii").valid_encoding?
p ("abc" + x).dup.force_encoding("ascii").valid_encoding?
p "abc#{x}".encoding
