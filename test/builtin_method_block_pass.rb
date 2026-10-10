# A builtin's Method passed as a block (`&4.method(:fdiv)`, or `&m` on a
# local holding it) takes what the block's yield passes, as many arguments
# as the builtin's arity: the wrapper took only what the program's .call
# sites pass, none here, and the builtin raised ArgumentError.
p [1, 2, 3].map(&4.method(:fdiv))
m = 6.method(:gcd)
p [4, 9, 10].map(&m)
p m.call(4), m.arity
p [2, 3].map(&10.method(:pow))
p [1, 2].map(&3.method(:quo))
p [5, 6].map(&"x".method(:center))
c = "x".method(:center)
p c.call(3), [5].map(&c), c.call(4, "*")
p ["b", "c"].map(&"abc".method(:index))
p [1, 4].select(&[1, 2, 3].method(:include?))
p [0, 2].map(&[7, 8, 9].method(:fetch))
p [1.5, 2.5].map(&2.0.method(:fdiv))
