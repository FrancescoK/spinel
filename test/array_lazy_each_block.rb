# `a.lazy.each { }` over an Array runs the block over each element and
# answers the Array, as `a.each { }` does. A lazy enumerator's own each
# had no emitter, and it raised NoMethodError.

a = [1, 2, 3]
r = a.lazy.each { |q| print q, " " }
puts
p r, r.equal?(a)
p [1.5, 2.5].lazy.each { |q| q }
p a.lazy.map { |x| x * 2 }.to_a
c = a.lazy.each { |q| q }
c[4] = 9
p a
p({ a: 1 }.lazy.map { |k, v| v }.to_a)
