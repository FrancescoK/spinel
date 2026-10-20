# `<=>` on a yield, with an Integer block and a block of another kind at
# another call site. The yield used to take its first site's kind, so an
# Integer block first and a String block second raised TypeError at run time
# (the String site's nil was stored in the Integer slot). CRuby: 1 then nil.
def w
  v = yield.<=>(2)
  p v
end

w { 7 }
w { "abc" }
w { 2.5 }
w { [3, 1] }

def w2
  v = yield.<=>(2)
  p v
end

w2 { "abc" }
w2 { 7 }
