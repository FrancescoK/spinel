def gather(a, *rest, k: "d" * 3, **opts, &blk)
  junk = (1..10).map { |i| "x#{i}" }
  rest.each { |r| r << junk.size.to_s }
  opts.each_value { |v| v << "o" }
  blk&.call(a)
  [a, rest, opts]
end
s = +"s"; t = s; u = +"u"; w = +"w"
20.times do |i|
  gather(s, u, s, k: "kk", z: w) { |x| x << "b" }
  tmp = Array.new(30) { |j| "#{i}-#{j}" }
end
p s.size, t.equal?(s), u.size, w.size
