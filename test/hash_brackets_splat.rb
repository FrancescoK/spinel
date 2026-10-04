# Hash[*args] spreads the arguments into Hash[]: one argument is a list of
# pairs or a Hash, an even count is alternating keys and values.
# activesupport's HashWithIndifferentAccess.[] is `new.merge!(Hash[*args])`.
# It was lowered as `args.to_h`, reading the argument list itself as the
# pairs, and the C did not compile.
def mk(*args) = Hash[*args]

p mk([[:a, 1], [:b, 2]])
p mk(:a, 1, :b, 2)
p mk({ c: 3 })
p mk("x", 1)
p mk
src = { d: 4 }
copy = mk(src)
copy[:e] = 5
p src
p copy
begin
  mk(:a, 1, :b)
rescue ArgumentError => e
  p e.message
end

# a pair list Hash[] cannot read raises its ArgumentError (Array#to_h's
# would be a TypeError)
[[[1, 2, 3]], [[[1, 2, 3]]], [[[]]]].each do |a|
  begin
    p mk(*a)
  rescue => e
    p [e.class, e.message]
  end
end
