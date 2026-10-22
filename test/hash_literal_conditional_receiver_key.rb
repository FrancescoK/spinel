# An empty Hash literal reached through a conditional or parentheses is the
# receiver of a key operation the way a bare `{}` is: the key decides its
# kind, so an Integer, Symbol or Array key is not converted to a String
# (`(c ? {} : {})[0] = 1` raised TypeError, #9971).
c = ARGV.size
p((true ? {} : {})[0] = 1)
p((c == 0 ? {} : {})[:a] = 2)
p((c > 0 ? {} : {})["k"] = "v")
p((c == 0 ? {} : {})[[1]] = 3)
x = (c == 0 ? {} : {})[5]
p x
p((c == 0 ? ({}) : {}).fetch(7, :none))
