# An Integer's &, | and ^ take only an Integer operand: any other fails to
# coerce, named as CRuby names it (nil, true, false, a Symbol and a Float by
# inspect, anything else by its class). A shift converts its count, and
# fails with "no implicit conversion". The same holds for an operand read
# out of a box, for a Bignum receiver, and under --int-overflow=promote,
# where `x & true` answered 1.

def t
  yield
rescue => e
  puts "#{e.class}: #{e.message}"
end

x = [1][ARGV.size]
t { p x & true }
t { p x | false }
t { p x ^ nil }
t { p x & "s" }
t { p x & 1.5 }
t { p x & :a }
t { p x & [1] }
t { p x << true }
t { p x >> nil }
t { p x << 1.5 }
t { p x + :a }
t { p (2**70) & true }
t { p (2**70) << "s" }

[3, true, :s, 1.5, nil, "s", [2]].each do |v|
  t { p 6 & v }
  t { p 6 | v }
  t { p 6 ^ v }
  t { p 1 << v }
  t { p 64 >> v }
end

n = 1
p n
n = nil
t { p n & true }
t { p n | 1.5 }
t { p n ^ "s" }
