# asctime and to_a on a Time read out of a container answer as on a typed
# Time: the C-style stamp and the ten fields.
t = Time.utc(1970, 1, 5, 0, 0, 1)
x = [t, 0][0]
p x.asctime
p x.to_a
l = Time.new(2000, 1, 2, 12, 30, 0, "+09:00")
y = [l, 0][0]
p y.asctime
p y.to_a == l.to_a
p ["s", 0][0].asctime rescue p $!.message
