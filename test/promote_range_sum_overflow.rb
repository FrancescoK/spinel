# spinel: int64
# Range sums keep their promoted total through typed and boxed calls.
n = 2**62
p (n..n+1).sum
p (n..n+1).sum(0)
p (n..n+1).sum(0.5)
p (n..n+1).sum(0r)
p (n..n+1).sum(2**64)
p (n..n+1).sum(-(2**62))
p (n...n+2).sum
p (2..1).sum(2**64)
[(n..n+1), nil].each do |range|
  if range
    p range.sum
    p range.sum(0)
    p range.sum(0.5)
    p range.sum(0r)
  end
end
