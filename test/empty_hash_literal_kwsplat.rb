# `**{}` spreads nothing. A literal empty hash as the spread source has no
# key or value type to merge, and the keyword list or hash literal holding it
# was refused.

pr = proc { |*a| a }
p pr.call(**{})                            #=> []
p pr.call(1, **{})                         #=> [1]

la = ->(*a, **o) { [a, o] }
p la.call(**{})                            #=> [[], {}]
p la.(1, **{})                             #=> [[1], {}]

def kw(**kw) = kw
p kw(**{})                                 #=> {}

def both(*a, **kw) = [a, kw]
p both(1, **{})                            #=> [[1], {}]
p both(1, **{}, k: 2)                      #=> [[1], {k: 2}]

p({**{}})                                  #=> {}
p({a: 1, **{}})                            #=> {a: 1}
p({**{}, "s" => 2})                        #=> {"s" => 2}
