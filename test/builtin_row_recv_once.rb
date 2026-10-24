# spinel: int64
# A builtin row reads its receiver once, whatever its own text does with it.
# A row naming $r twice repeats the rendered text, so the receiver's call ran
# for each place it stood: Integer#abs2, #magnitude, #polar and Float#abs2,
# #nonzero?, #polar each ran it twice, and Integer#divmod read it once for
# the quotient and again for the modulo. Integer#size names it nowhere, and
# dropped the call instead. Integer#magnitude is an alias of #abs, down to
# the overflow its own `-($r)` answered as a negative magnitude.
$n = 0

def int_recv
  $n += 1
  -3
end

def float_recv
  $n += 1
  -2.5
end

$n = 0
p int_recv.divmod(2), $n
$n = 0
p int_recv.abs2, $n
$n = 0
p int_recv.magnitude, $n
$n = 0
p int_recv.polar, $n
$n = 0
p int_recv.size, $n
$n = 0
p float_recv.abs2, $n
$n = 0
p float_recv.nonzero?, $n
$n = 0
p float_recv.polar, $n
