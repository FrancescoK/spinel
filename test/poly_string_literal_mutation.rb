# A String a poly slot receives through a ternary, a Hash value or a case/when
# arm is changed in place by a String mutator, so an alias sees the change.
# Spinel literals are frozen (frozen_string_literal: true, no opt-out), so the
# mutable values come from dup / +"" and a bare literal raises FrozenError.

c = ARGV.empty?
k = ARGV.size

x = c ? "a".dup : 1
y = x
x << "b"
p [x, y]

h = {k: c ? +"h" : [1]}
v = h[:k]
h[:k] << "i"
p [h, v]

z = case k
    when 0 then "w".dup
    when 1 then [1]
    else 2
    end
za = z
z << "x"
z.upcase!
p [z, za]

m = case k
    in 0 then +"m"
    in 1 then [2]
    else 3
    end
ma = m
m.replace("pat")
p [m, ma]

q = c ? "lit" : 1
begin
  q << "!"
rescue FrozenError => e
  p e.class
end
p q
