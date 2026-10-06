# ("a".."e").step(k) { } walks every k-th member and answers the range, as
# CRuby 4.0 does: it answered the Array of the members it walked, since the
# call was lowered to step(k).each { } over the Enumerator. An endless String
# Range walks by succ until the block breaks, and a step of zero or less
# yields the begin alone (CRuby yields it once and stops).

r = "a".."e"
p(r.step(2) { |x| p x })
p(("a"..."e").step(3) { |x| p x })
p(("a".."e").step { |x| p x })
n = 0
("a".."e").step(0) { |x| n += 1; break if n > 5 }
p n
n = 0
("e".."a").step(-1) { |x| n += 1 }
p n
n = 0
("a"..).step(2) { |x| p x; n += 1; break if n > 3 }
p(("az".."bc").step(2) { |x| p x })
