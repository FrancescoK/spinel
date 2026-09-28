# A typed Hash compared with an empty `{}` literal is equal exactly when it
# is empty; the literal's own type was unknown and the pair was folded to
# "never equal".
def f(opt)
  h = {}
  opt.each { |k, v| h[k.to_s] = v if v }
  r = [1]
  r << h if h != {}
  p h != {}, h == {}, r.length
end
f({})
f({a: 1})
g = {}
p g != {}
p g == {}
h = {"a" => 1}
p h == {}
p h != {"a" => 1}
p({} == {"a" => 1}, {} != g)
