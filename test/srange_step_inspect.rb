# A String Range's step(n) answers an Enumerator over the Range, so it
# inspects as CRuby's does ("a".."e":step(2)) rather than over the stepped
# members it holds.
r = ("a".."e")
e = r.step(2)
p e
puts e.inspect
p e.to_a, e.map(&:upcase), e.next
r.step(2) { print _1 }
puts
p (r % 2).to_a
