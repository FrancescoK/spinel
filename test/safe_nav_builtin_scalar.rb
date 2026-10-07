# `v&.fdiv(2)` and the other Integer / Float / Comparable methods written in
# Ruby (builtins/integer.rb, builtins/comparable.rb) skip the call when v is
# nil; the rewrite onto the method's copy had dropped the `&.`.
def fd(v) = v&.fdiv(2)
p fd(nil), fd(3)
def dg(v) = v&.digits
p dg(nil), dg(12)
def cl(v) = v&.clamp(1, 5)
p cl(nil), cl(9)
def gc(v) = v&.gcd(4)
p gc(nil), gc(6)
def bw(v) = v&.between?(1, 5)
p bw(nil), bw(3)
def bl(v) = v&.bit_length
p bl(nil), bl(8)
def cf(v) = v&.clamp(1.5, 2.0)
p cf(nil), cf(9.0)
p 3&.fdiv(2), 12&.digits, 7.clamp(1, 5), 2.5.between?(1, 3)
