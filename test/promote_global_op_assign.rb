# Under --int-overflow=promote an Integer global widens to a boxed slot as a
# local does, so an op-assign past int64 answers a Bignum.
$i = 2**62
$i += 2**62
p $i
$j = 2**40
$j *= 2**40
p $j
$k = 3
$k **= 50
p $k
$l = 1
$l <<= 70
p $l
$m = 2**62
p($m += 2**62)
p($m -= 1)
$n = 5
$n += 1
p $n
p $n.even?
$c = 0
def bump = $c += 2**62
bump
bump
bump
p $c
$s = 10
$s -= 2**63
$s -= 2**63
p $s
