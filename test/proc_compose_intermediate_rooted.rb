# spinel: gc-stress
# A composed proc (`f >> g`) calls the first proc, then hands its
# answer to the second. That answer is often a new value -- here an Array --
# that nothing else holds, and the second proc's call allocated and freed it
# before the proc read it: under SPINEL_GC_STRESS=1 `v[0]` read nil.
made = [proc { |x| [x, "m#{x}"] }, 1][0]
k = made >> proc { |v| [v[0], v[1].size] }
p (1..3).to_h(&k)
j = made >> proc { |v| [v[1], v[0] + 1] }
p [4, 5].map(&j)
p (made >> proc { |v| v.reverse }).call(6)
