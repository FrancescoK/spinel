def f(x)
  case x
  in {name: String => n} then n << "!"
  end
end
s = +"abc"
f({name: s})
p s
