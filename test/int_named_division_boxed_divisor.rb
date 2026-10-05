# Integer's named divisions with a divisor whose kind is only known at run
# time. `modulo` did not compile at all: the divisor went to sp_imod as a raw
# sp_RbVal, so a program containing the line could not be built. It converts
# the boxed value now, the way its sibling `remainder` already did.
b = [6, "x"].first          # a boxed Integer
p 17.modulo(b)
p 17.remainder(b)
p 17.div(b)
p 17 % b
p 17 / b
p(-17.modulo(b))
p(-17.remainder(b))

z = [0, "x"].first
begin
  p 17.modulo(z)
rescue ZeroDivisionError => e
  puts "ZeroDivisionError: #{e.message}"
end

# A boxed Float divisor: CRuby's div floors the real quotient (an Integer,
# 17.div(2.5) is 6), which this Integer-typed call now answers by the
# divisor's run-time kind; it used to cut the divisor to 2 and answer 8.
# CRuby's modulo answers a Float (2.0), which the Integer-typed call cannot
# hold, so spinel raises NotImplementedError there instead of answering the
# modulo of the cut divisor (1); the rescue prints what CRuby answers, so
# the two runs agree only when spinel raised. `remainder`, migrated to Ruby
# (builtins/integer.rb), dispatches on the runtime kind as `%` does.
f = [2.5, "x"].first
m = begin
  17.modulo(f)
rescue NotImplementedError
  2.0
end
puts "modulo    #{m}   (CRuby 2.0)"
puts "remainder #{17.remainder(f)}   (CRuby 2.0, and right)"
puts "div       #{17.div(f)}   (CRuby 6)"
puts "pct       #{17 % f}   (CRuby 2.0, and right)"
puts "/         #{17 / f}   (CRuby 6.8, and right)"
