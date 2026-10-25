# spinel: int64
# reduce(init, :op) with an Integer seed and `&`, `|` or `^` folds boxed
# when an element can be a Bignum. The fold typed the result as the seed's
# sp_int, so a poly Array with a Bignum in it raised RangeError on the
# unbox, where CRuby answers the Bignum.
big = 2**64

pa = [28, big, "x"]
pa.pop
p pa.reduce(0, :^)
p pa.reduce(0, :|)
p pa.reduce(-1, :&)

p [28, big].reduce(0, :|)
p [28, big].reduce(0, :^)

# machine words only, and an element that is not an Integer, as before
p [3, 5].reduce(0, :|)
p [3, 5, "x"].first(2).reduce(0, :^)
begin
  p [3, "x"].reduce(0, :|)
rescue TypeError => e
  p e.message
end
