# send / public_send / __send__ with a literal name of an Enumerable method
# written in Ruby (tally, each_with_object, ...): the call was retargeted
# after those methods were bound to their call sites, and raised
# NoMethodError for an Array's or a Hash's own method.
x = [1, 1, 2]
p x.send(:tally)
p x.public_send(:tally, {})
p [1, 2].send(:each_with_object, {}) { |v, h| h[v] = v * 10 }
p({ a: 1 }.public_send(:each_with_object, []) { |kv, a| a << kv })
p [1, 2, 3].__send__(:each_slice, 2).to_a
p (1..4).send(:each_cons, 2).to_a
p %w[a b a].send(:tally).max_by { |_, n| n }
