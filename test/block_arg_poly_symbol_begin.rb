# `m(&v)` where v is a boxed value that holds a Symbol at run time: the
# Symbol literals that flow into the value each get the proc `&:name` makes
# (block_arg_poly_symbol.rb). The walk that finds them stopped at a `begin` with a rescue clause,
# so a Symbol chosen there reached the call as a bare value and raised
# TypeError ("callable object is expected").
def kc(x, &b) = b ? b.call(x) : :none

def run(n)
  pr = proc { |v| v * 10 }
  s = begin
    raise ArgumentError, 'x' if n > 0
    :succ
  rescue ArgumentError
    pr
  end
  p kc(3, &s)
  p [1, 2].map(&s)
end

run(0)
run(1)
