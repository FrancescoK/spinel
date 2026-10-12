# A String bang on a boxed receiver (an element of a mixed Array, a value
# of a mixed Hash, over `<<`), as an argument of `p` taken as a value, which
# runs its arguments ahead of each other: its box is the receiver's own box,
# or nil when the bang changed nothing, and the receiver runs once (tick
# counts each `<<`).
$n = 0
def tick(x) = ($n += 1; x)
$a = [+"ab", 1]
x = (p ($a[0] << tick("z")).upcase!, $a[0])
p x, $n, x[0].equal?($a[0])
x = (p ($a[0] << tick("")).upcase!, $a[0])
p x, $n
$h = {k: +"cd", j: 2}
x = (p ($h[:k] << tick("z")).capitalize!, $h[:k])
p x, x[0].equal?($h[:k])
x = (p ($h[:k] << tick("a")).sub!("a", "A"), $h[:k])
p x, $n
def kept = (p ($a[0] << tick("q")).downcase!, $a[0])
y = kept
p y, y[0].equal?($a[0]), $n
