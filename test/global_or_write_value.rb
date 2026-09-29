# `$g ||= v` and `$g &&= v` read as values answer the slot after the write.
def f = ($g ||= :x)
p f, f
$h = 1
def h2 = ($h &&= "three")
p h2, $h
def k = ($k ||= [1])
p k.push(2), $k
x = ($m ||= 5) + 1
p x
$n = nil
p($n &&= 9)
p [$o ||= 1.5, 2]
def memo = $memo ||= begin; puts "once"; {a: 1}; end
p memo, memo
$z = 0
p($z ||= 7)
p(($q ||= 3) > 2 ? "big" : "small")
$sym = nil
v = ($sym ||= :a)
p v
