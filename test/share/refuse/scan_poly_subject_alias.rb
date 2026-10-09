# A boxed subject read from an Array the block changes.
t = +"abc"
a = [t]
s = a.first
acc = []
s.scan(/./) { |m| acc << m; m << "!"; a[0] << "z" if acc.size == 1 }
p acc
p s
