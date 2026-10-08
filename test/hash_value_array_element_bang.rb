# An Array held as a Hash's value is read back boxed, through `h.each { |k,
# vs| }`, `h.each_value`, `h[k]` or a local bound to `h[k]`. Iterating it
# and mutating each element in place (strip!, upcase!, <<) changed a copy:
# the iteration gate passed over a boxed receiver, so the Strings stored in
# the Array stayed plain and the Hash printed them unchanged. WEBrick's
# parse_header strips its header values this way.
h1 = { "k" => [+" 1"] }
h1.each { |k, vs| vs.each(&:strip!) }
h2 = { "k" => [+" 2"] }
h2.each { |k, vs| vs.each { |v| v.strip! } }
h3 = { "k" => [+" 3"] }
h3.each_value { |vs| vs.each(&:strip!) }
h4 = { "k" => [+" 4"] }
h4["k"].each(&:strip!)
h5 = { "k" => [+" 5"] }
vs = h5["k"]
vs.each(&:strip!)
h6 = { "k" => [+" 6"] }
h6.each { |k, vs| vs[0].strip! }
p h1, h2, h3, h4, h5, h6

h7 = { "a" => [+"x", +"y"], "b" => [+"z"] }
h7.each { |k, vs| vs.each { |v| v << "!" } }
h7.each_value { |vs| vs.each(&:upcase!) }
p h7
