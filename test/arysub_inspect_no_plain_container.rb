# An Array or Hash subclass instance renders its elements in a program
# that has no plain Array or Hash value. The inspect hooks the runtime
# walks containers through were left out there, so `p` printed {}.
class A < Array; end
class H < Hash; end
class F < Array; end

a = A.new
a << 1
a << 2
p a
puts a.inspect

h = H.new
h[:k] = 1
h[:j] = :q
p h
puts h.to_s

f = F.new
f << 1.5
p f
