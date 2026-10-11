# casecmp? folds characters: a BINARY String's high bytes, and the bytes of
# a Symbol made from one, are no characters and do not fold into each other
# ("\xC3" is not the capital of "\xE3"), while UTF-8 text still folds.
p "\xC3".b.casecmp?("\xE3".b)
p "\xC3".b.to_sym.casecmp?("\xE3".b.to_sym)
p "ABC".b.casecmp?("abc".b)
p "É".casecmp?("é")
p :"É".casecmp?(:"é")
p "Straße".casecmp?("STRASSE")
