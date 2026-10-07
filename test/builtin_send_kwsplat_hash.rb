def hev(hash, method, *args, **) = hash.send(method, *args, **)

p hev({a: 1}, :key?, :a)
p hev({x: 1}, :merge, {z: 3})
p hev({x: 1}, :==, y: 2)
p hev({x: 1}, :update, y: 2)
p hev({x: 1}, :merge!, y: 2)
p hev({x: 1}, :merge)
p hev({x: 1}, :merge, y: 2)
