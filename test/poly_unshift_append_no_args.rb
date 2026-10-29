# unshift and append with no argument on an Array read out of a general
# (mixed) Array answer that Array, unchanged; a frozen one raises
# FrozenError, and a value that is not an Array raises NoMethodError.

b = [[1], "s"]
p b[0].unshift
p b[0].append
p b[0].unshift.equal?(b[0])
y = b[0].append.push(2)
p y, b

f = [[1, "x"].freeze, "s"]
begin
  f[0].unshift
rescue FrozenError => e
  p e.class
end
begin
  p f[0].append
rescue FrozenError => e
  p e.class
end

begin
  b[1].unshift
rescue NoMethodError => e
  p e.class
end
b.each { |e| p((e.append rescue $!.class)) }

def m(x) = x.unshift
p m([1, "a"])
