# --share-strings: a String Range's endpoint that is changed in place is the
# handle the Range keeps, and `next` hands that handle on as a block's
# value, so a change through the answer reaches the endpoint, as the block's
# last value does. (An endpoint the Range keeps as its bytes is the String
# itself: test/srange_endpoint_next_value.rb.)
# spinel: gc-minor
d = +"d"; f = +"f"; s = d...f
f << "g"
m = proc { next s.end }
p m.call.equal?(f), m.call
m.call << "!"
p f, s.end
n = proc { |k| next s.min if k == 1; s.begin }
n.call(1) << "?"
p d, s
