s = +"abc"
case {a: s, b: 1}
in {a: String => t, **rest}
  t << "!"
end
p s
