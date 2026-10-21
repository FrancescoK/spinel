# A boxed nil global and a parenthesized Hash fallback use the Hash slot.
$c = nil
h = $c || (puts :fb; {})
h[:k] = 1
p h
$c = nil
h = $c || {}
h[:k] = 2
p h
$c = nil
h = $c || ({})
h[:k] = 3
p h
c = nil
h = c || (puts :local; {})
h[:k] = 4
p h
