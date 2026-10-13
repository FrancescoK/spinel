# A String Range's endpoint given by `next` as a block's value is the
# endpoint itself. Under --share-strings the `next` handed on the handle
# route's answer, which wraps a new handle around an endpoint the Range does
# not keep as one, so the block answered another object; the block's last
# value was already the endpoint.
a = +"a"; b = +"c"; r = a..b
h = Hash.new { |hh, k| next r.end }
p h[1].equal?(b)
g = Hash.new { |hh, k| next r.begin }
p g[1].equal?(a)
c = Hash.new { |hh, k| next r.end if k == 1; r.begin }
p c[1].equal?(b), c[2].equal?(a)
pr = proc { |k| next r.min if k == 1; next r.max if k == 2; r.max }
p pr.call(1).equal?(a), pr.call(2).equal?(b)
l = -> { next r.last }
p l.call.equal?(b)
e = (a..)
q = proc { next e.begin }
p q.call.equal?(a), q.call
