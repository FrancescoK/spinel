# Encoding's class-level queries have fixed answers in Spinel, whose strings
# are UTF-8 or binary: default_internal is nil, default_external UTF-8, and
# Encoding.find of a literal name is that encoding. They were refused as
# class methods no class defines.
p Encoding.default_internal
p Encoding.default_external
p Encoding.default_external == Encoding::UTF_8
p Encoding.find("utf-8") == Encoding::UTF_8
p Encoding.find("BINARY") == Encoding::ASCII_8BIT
Encoding.default_internal = nil
p "x".encoding == Encoding.default_external
