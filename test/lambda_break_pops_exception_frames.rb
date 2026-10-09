# spinel: gc-stress
# spinel: share
# A lambda break leaves its exception frames and handled-exception slots.
# Evaluate the value before popping them so a raising value is rescued.
halved = lambda do |x|
  begin
    break x / 2 if x.even?
  rescue
  end
  :odd
end

parsed = lambda do |s|
  begin
    break Integer(s)
  rescue ArgumentError
    break :bad
  end
end

named = lambda do |i|
  begin
    begin
      break String.new("n#{i}") if i > 0
    rescue
    end
  rescue
  end
  nil
end

bare = lambda do |x|
  begin
    break if x
  rescue
  end
  nil
end

multiple = lambda do |x|
  begin
    break x, String.new("pair")
  rescue
  end
end

ensured = lambda do |x|
  begin
    break x if x > 0
  ensure
    GC.start
  end
  :tail
end

looped = lambda do
  i = 0
  while i < 2
    i += 1
    break if i == 1
  end
  i + 10
end

100.times do |i|
  halved.call(i * 2)
  parsed.call("7")
  parsed.call("bad")
  named.call(i + 1)
  bare.call(true)
  multiple.call(i)
  ensured.call(i + 1)
end
p [halved.call(8), halved.call(3), parsed.call("6"), parsed.call("bad")]
p [named.call(7), named.call(0), bare.call(true), bare.call(false)]
p multiple.call(5)
p [ensured.call(5), looped.call]
begin
  raise "after"
rescue => e
  p e.message
end
p $!
