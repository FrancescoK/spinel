s = "\xE3\x81\x82\xff\xfe".b
p s.tr("\xE3\x81\x82".b, "abc")
p s.tr_s("\x81\x82".b, "z")
p s.delete("\x80-\xfe".b)
p s.delete("\x80-\xff".b, "^\xff".b)
p s.count("\x80-\xff".b)
p s.count("^\xE3".b)
p s.count("\x80-\xff".b, "^\xff".b)
p "\xE3\xE3\x81\x81".b.squeeze("\xE3\x81".b)
p "\xE3\x81\x82\xE3\x81\x82".b.squeeze
p "\xE3\xE3\xff\xff".b.squeeze("\x80-\xff".b, "^\xff".b)
p "\xE3\x81\x82x\xE3".b.lstrip("\xE3".b)
p s.delete("\xff".b).encoding

b = [s, 1][0]
p b.count("\x80-\xff".b)
p b.delete("\x80-\xfe".b)
p b.squeeze

p "あいa".count("^a")
p "あいa".delete("い")
p "ああい".squeeze

n = "a\0b^c"
p n.count("^\0"), n.delete("^\0"), n.tr("^\0", "x"), n.b.count("^\0".b), "x^y".count("^")
