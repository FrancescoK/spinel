# Array#pack writes the native int directives i/I (int) and j/J (intptr_t),
# and l!/L! (l_/L_) as the native long, as CRuby and unpack read them: pack
# wrote nothing for i/I/j/J and a 32-bit l!.
p [1].pack("i").bytes
p [-2, 3].pack("i2").unpack("i2")
p [70_000].pack("I").unpack1("I")
p [5].pack("j").unpack1("j")
p [6].pack("J").bytesize == [6].pack("Q").bytesize
p [1, 2].pack("i>i<").bytes
p [1, "x"].pack("I a").bytes
p [-1].pack("l!").bytesize == [-1].pack("q").bytesize
p [-1].pack("l!").unpack1("l!")
p [7, 8].pack("L_2").unpack("L_*")
p [9].pack("l").bytesize
p ["hello"].pack("p").bytesize == [0].pack("J").bytesize
p ["hello"].pack("P").bytesize == [0].pack("J").bytesize
