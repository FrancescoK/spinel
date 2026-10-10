# A typed-array adapter Method (`arr.method(:push)`, `:[]`, `:[]=`) answers
# what the Array op answers, in every --int-overflow mode. Under promote the
# adapter returns a boxed value; the call once read it as the raw array
# pointer, and push's answer crashed in inspect.
sa = ["x"]
p sa.method(:push).call("y")
p sa.method(:[]).call(1)
p sa.method(:[]=).call(0, "z")
p sa
ia = [1, 2]
p ia.method(:push).call(3)
p ia.method(:[]).call(2)
p ia.method(:[]=).call(0, 7)
p ia
m = [sa.method(:push)][0]
p m.call("w")
p sa.length
