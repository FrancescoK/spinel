# Fiber[] / Fiber[]= and Thread#[] / #[]= take a key object through its
# #to_str, as a String naming the same Symbol; any other object is a
# TypeError.
class K; def to_str = "Foo"; end
class N; end
key = K.new
Fiber[key] = 42
p Fiber["Foo"], Fiber[:Foo], Fiber[key]
Fiber[:bar] = 1
p Fiber[K.new]
Thread.current[key] = 7
p Thread.current[:Foo], Thread.current["Foo"], Thread.current[key]
p((Fiber[N.new] rescue $!.class))
begin; Fiber[1] = 2; rescue => e; p e.message; end
i = 0
bk = [key, 1][i]
p Fiber[bk]
