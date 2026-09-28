# index, rindex and their start/pos forms count one position per byte in an
# ASCII-8BIT string, whatever its bytes spell in UTF-8.
s = "\xC3\xA9\xFF".b
p s.index("\xFF".b)
p s.index("\xA9".b)
p s.rindex("\xC3".b)
p s.index("\xFF".b, 1)
p s.index("\xFF".b, -1)
t = "\xC3\xA9x\xC3\xA9x".b
p t.index("x".b), t.index("x".b, 3), t.rindex("x".b), t.rindex("x".b, 4)
p t.index("zz".b), t.index("x".b, 9)
# a UTF-8 string still counts characters
u = "éxéx"
p u.index("x"), u.index("x", 2), u.rindex("x"), u.rindex("x", 2)
