# spinel: reject-encode: String#encode with an option hash known only at run time
# A computed key could name xml: or a newline option, which change the bytes
# and which the runtime does not read, so a key known only at run time is
# refused. (A `**` operand's options are read at run time.)
k = :invalid
p "x".encode("UTF-8", k => :replace)
