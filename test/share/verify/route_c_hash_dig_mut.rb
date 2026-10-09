s = +"abc"
t = s
{a: {b: s}}.dig(:a, :b) << "!"
p s
p t
