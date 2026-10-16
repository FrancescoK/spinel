# A cycle of methods whose way out answers a parameter (here the String the
# caller holds) is not a cycle of new Strings. The compiler once counted
# bb, and its calls, as new (#9080); cycle_way_out_is_parameter.claims is
# what it claimed then, and the oracle must disprove it.
def aa(x, n)
  if n > 0
    bb(x, n - 1)
  else
    x
  end
end
def bb(x, n) = aa(x, n)
s = +"held"
r = [bb(s, 3)]
r.each { |e| e << "." }
p s, r, r[0].equal?(s)
