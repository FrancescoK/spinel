def bx(v) = [v, 1, "s", nil][0]
def t = yield rescue "#{$!.class}: #{$!.message}"

p(t { "12".to_i(10, foo: 1) })
p(t { "12x".chomp("x", foo: 1) })
p(t { "121".index("1", 1, foo: 1) })
p(t { "ab".center(5, "*", foo: 1) })
p(t { [1, 2].first(1, foo: 1) })
p(t { [1, 2].join("-", foo: 1) })
p(t { [3, 1].min(1, foo: 1) })
p(t { [[1], 2].flatten(1, foo: 1) })
p(t { 10.to_s(2, foo: 1) })
p(t { 2.pow(3, 5, foo: 1) })
p(t { 10.digits(10, foo: 1) })
p(t { 1.55.floor(1, foo: 1) })
p(t { 1r.floor(1, half: :up) })
p(t { "12".to_i(foo: 1) })
p(t { [1, 2].first(foo: 1) })

p(t { bx([1, 2]).first(1, foo: 1) })
p(t { bx("ab").center(5, "*", foo: 1) })
p(t { bx(10).digits(10, foo: 1) })
p(t { bx([1, 2]).first(1, 2) })
p(t { bx("ab").center(5, "*", "x") })

p(t { "12".send(:to_i, 10, foo: 1) })
p(t { [1, 2].send(:join, "-", foo: 1) })

p 2.5.round(half: :even)
p 1r.round(1, half: :up)
p "a\nb\n".lines(chomp: true)
p [1, 2, 3].sample(random: Random.new(1)).class
p "12".to_i(10)
p [1, 2].join("-")
p [3, 1].min(1)
