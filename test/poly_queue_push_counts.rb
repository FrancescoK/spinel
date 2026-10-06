# push / << / enq on a value that is a Queue or a SizedQueue only at run
# time (read out of an array): SizedQueue#push(obj, non_block) is one push,
# and a count the queue does not take is its ArgumentError, named by its
# own range. push with none raised NoMethodError, push(obj, true) pushed
# the flag as an element, and a third argument was pushed too.
qs = [Queue.new, SizedQueue.new(10)]
qs.each do |x|
  x.push(1)
  x << 2
  x.enq(3)
  p x.size
end
qs.each do |x|
  begin
    x.push
  rescue ArgumentError => e
    p e.message
  end
  begin
    x.push(1, false, 3)
  rescue ArgumentError => e
    p e.message
  end
  begin
    x.push(1, true)
    p x.size
  rescue ArgumentError => e
    p e.message
  end
  begin
    r = x.push
    p r
  rescue ArgumentError => e
    p e.message
  end
end
p qs.map { |x| x.push(7).equal?(x) }
xs = [[1], "s"]
v = xs[0]
v.push
v.push(2, 3)
p v
p v.push.size
begin
  xs[1].push(1, 2)
rescue NoMethodError => e
  p e.message
end
begin
  xs[1].push
rescue NoMethodError => e
  p e.message
end
