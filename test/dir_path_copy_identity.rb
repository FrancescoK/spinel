# spinel: gc-stress
# Dir#path and Dir#to_path return a new, unfrozen String on each call:
# on an open handle, a boxed one, and after close.
d = Dir.open(".")
a = d.path
b = d.path
p [a.equal?(b), a.frozen?]
p [a, b]
p d.to_path.equal?(d.to_path)
x = [d, 1][0]
p x.path.equal?(x.path)
p x.path
d.close
p d.path.equal?(d.path)
p d.path
