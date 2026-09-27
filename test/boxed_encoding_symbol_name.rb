# `name` on an Encoding (always carried boxed) and on a Symbol read out of
# a container answers a frozen String, as CRuby does and as a typed Symbol
# answers.
e = "x".encoding
p e.name
p e.name.frozen?
b = [Encoding::UTF_8, 0][0]
p [b.name, b.name.frozen?]
s = [:Foo, 0][0]
p s.name
p [s.name.frozen?, s.name.class]
c = [Integer, :sym][0]
p c.name
p [Encoding::ASCII_8BIT, :x, String].map { |v| v.name }
