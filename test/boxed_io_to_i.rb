# A boxed IO's to_i is its file descriptor, as a typed one's is (it answered 0).
x = [$stdout, 1][0]
p x.to_i
y = [$stderr, 1][0]
p y.to_i
p $stdout.to_i
f = File.open(__FILE__)
z = [f, 1][0]
p z.to_i == f.fileno
f.close
p [3, 1][0].to_i
