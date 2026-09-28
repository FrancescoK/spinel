# chunk, slice_before and slice_after with a |k, v| block over a Hash's
# pairs splat each pair across k and v, as CRuby's yield of one value does,
# on a typed Hash and on one read out of a container.
h = { a: 1, b: 2, c: 3 }
p h.slice_before { |k, v| v.even? }.to_a
p h.slice_after { |k, v| v.even? }.to_a
p h.chunk { |k, v| v.odd? }.to_a
x = [h, 0][0]
p x.slice_before { |k, v| v.even? }.to_a
p x.slice_after { |k, v| k == :b }.to_a
p x.chunk { |k, v| v % 2 }.to_a
p h.slice_before { |kv| kv[1].even? }.to_a
# only an element that is an Array splats; any other binds k, with v nil
p [1, [2, 3], 4].slice_before { |a, b| b == 3 }.to_a
# the first two params of a longer block, and an Array of pairs
p [[:x, 1], [:y, 1], [:z, 2]].chunk { |k, v, w| [v, w] }.to_a
