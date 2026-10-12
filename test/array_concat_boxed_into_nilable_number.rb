# Array#concat as a statement, into an Integer or Float array, with an
# argument that stays boxed: each element, nil included, is stored whole

def feed(into, bytes)
  into.concat(bytes)
  nil
end

def feed_f(into, xs)
  into.concat(xs)
  nil
end

a = [1, 2]
feed(a, [3, nil])
feed(a, "x" == "y" ? 1 : [4])
p a
p a.compact.sum

f = [1.5]
feed_f(f, [2.5, nil])
feed_f(f, "x" == "y" ? 1 : [4.5])
p f
p f.compact.sum
