# A block that changes in place the Strings an iterator hands it, called
# on a receiver in parentheses after another statement, `(n += 1;
# u).each { |e| e << "!" }`, changes the Array's elements, as it does
# without the parentheses: here the Array is boxed (`u = (n += 1; [])`)
# and filled by a multiple assignment. A global Array whose element is a
# new String in parentheses compiles as the same Array without them.
n = 1
u = (n += 1; [])
u << +"q"
u[0], u[1] = "a#{n}", "b".dup
(n += 1; u).each { |e| e << "!" }
p u

w = (n += 1; [])
w << +"x" << "y".dup
(n; w).each_with_index { |e, i| e << i.to_s }
p w

v = []
v[0], v[1] = "c#{n}", "d".dup
(n += 1; v).each { |e| e << "?" }
p v, n

# a global Array whose element is a new String in parentheses, or gets one
# pushed, changed through each (on the global in parentheses too)
$h = [(2; "h".dup)]
$h.each { |e| e << "?" }
$j = []
$j << (1; "k".dup)
$j.each { |e| e << "?" }
$l = ["g".dup]
(nil; $l).each { |e| e << "?" }
p $h, $j, $l
