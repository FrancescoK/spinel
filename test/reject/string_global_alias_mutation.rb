# A local assigned from a String global is another name for the global's
# String. No global is a shared handle yet, so the local holds a copy and
# the append never reaches $g: refused, not compiled with "a".
$g = +"a"
t = $g
t << "!"
p $g
