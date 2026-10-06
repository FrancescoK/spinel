# Array#combination, #permutation and their repeated forms with no block,
# on a receiver that is boxed or may be nil, with a count that is not a
# plain Integer: a boxed one, or (under --int-overflow=promote) a local the
# promote mode boxes. The poly-array and boxed-receiver arms passed the count
# with emit_expr into the runtime's sp_int parameter, where the typed
# Integer-array arm already took it through emit_int_expr, so the generated C
# did not build. The count now takes the Integer slot's conversion in every
# arm: a boxed Integer unboxes, and a nil or a Float is CRuby's TypeError or
# truncation.

def t(k)
  r = k == 0 ? [1, 2, 3] : nil
  n = [2, :x][k]
  p r.combination(n).to_a
  p r.permutation(n).to_a
  p r.repeated_combination(n).to_a.size
  p r.repeated_permutation(n).to_a.size

  b = [[1.5, "a"], :x][k]
  p b.combination(n).to_a
  p b.permutation([1, nil][k]).to_a
  c = 1
  p b.repeated_combination(c).to_a
  p b.repeated_permutation(c + 1).to_a.size

  s = k == 0 ? ["x", "y"] : nil
  p s.permutation(n).to_a
  p s.combination([2.0, 1][k]).to_a
  begin
    p r.combination([nil, 1][k]).to_a
  rescue TypeError => e
    p e.message
  end
end

t(ARGV.size)
