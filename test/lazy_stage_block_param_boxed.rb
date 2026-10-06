# A lazy stage's block parameter is the boxed element the pipeline hands
# it, whatever the block does with it: `x << v` in the body typed it as an
# Array, the element was read as one, and the program crashed.

p [1, 2].lazy.map { |y| y << 1 }.first
p [1, 2, 3].lazy.select { |y| (y << 2) > 4 }.to_a
a = [[1]]
p a.lazy.map { |x| x << 2 }.first
p a
h = [{k: 1}]
p h.lazy.map { |x| x.merge!(j: 2) }.first(1)
p ["a", "b"].lazy.map { |x| x + "!" }.to_a
p ["a", "b"].lazy.reject { |x| x == "a" }.map { |x| x.upcase }.first
