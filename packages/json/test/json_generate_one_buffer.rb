require "json"
# JSON.generate writes keys, Strings and numbers straight into one buffer,
# which starts in a 512-byte array on the stack and moves to the heap when a
# document outgrows it. These cross that size with every kind of leaf, escape
# the bytes on both sides of it, and leave a #to_json early (a raise, a throw)
# with the buffer still small, outgrown, and moved.

# every escape, and runs of plain bytes between them
esc = "a\"b\\c\nd\te\rf\bg\fh\u0001i\u001fj\u007fk/l"
puts JSON.generate({"s" => esc, esc => 1})
puts JSON.generate(["", "\"", "\\", "\n\n", "x" * 3, "é ü 日本"])

# documents on both sides of 512 bytes, the escapes falling across it: a long
# plain run, then escapes; escapes only; and plain bytes between escapes, each
# compared whole with the document written out by hand
[480, 505, 506, 507, 508, 509, 510, 511, 512, 520, 1500].each do |n|
  s = JSON.generate({"k" => "x" * n + "\n\"" + "y" * 3})
  t = JSON.generate(["\t" * (n / 2)])
  u = JSON.generate(["a\"" * (n / 3)])
  puts "#{n} #{s.size} #{s == "{\"k\":\"" + "x" * n + "\\n\\\"yyy\"}"} " \
       "#{t.size} #{t == "[\"" + "\\t" * (n / 2) + "\"]"} " \
       "#{u.size} #{u == "[\"" + "a\\\"" * (n / 3) + "\"]"}"
end

# every kind of key and leaf
puts JSON.generate({1 => 2, -3 => -4, 0 => 0, :sym => :val, true => false, nil => nil, 1.5 => 2.25})
puts JSON.generate([0, -1, 7, 1234567, -987654321, 1.0, -0.0, 0.1, 1e20, 1.5e-7, 123.456, 1e-10])
puts JSON.generate({"big" => Array.new(200) { |i| i * 7 - 300 }}).size

# a #to_json of the program's own, small and outgrown
class Pt
  def initialize(x, y, name)
    @x = x
    @y = y
    @name = name
  end

  def to_json(*args)
    {x: @x, y: @y, name: @name}.to_json(*args)
  end
end
pts = Array.new(30) { |i| Pt.new(i, i * 0.5, "p#{i}" + "z" * (i * 20)) }
doc = JSON.generate({points: pts, info: "end"})
puts doc.size, doc[0, 60], doc[-40, 40]

# a #to_json that raises, with the outer buffer still small and outgrown
class Bad
  def initialize(n)
    @n = n
  end

  def to_json(*args)
    raise ArgumentError, "bad #{@n}" if @n > 2
    {n: @n, pad: "q" * (@n * 300)}.to_json(*args)
  end
end
[[Bad.new(1), Bad.new(3)], [Bad.new(1), Bad.new(2), Bad.new(2), Bad.new(5)]].each do |list|
  begin
    puts JSON.generate(list)
  rescue ArgumentError => e
    puts "rescued #{e.message}"
  end
end
puts JSON.generate([Bad.new(1), Bad.new(2)]).size

# a #to_json that throws out of the walk
class Thrower
  def to_json(*args)
    throw :out, "thrown"
  end
end
r = catch(:out) { JSON.generate(["a" * 600, Thrower.new]) }
puts r
r = catch(:out) { JSON.generate(["a", Thrower.new]) }
puts r

# nesting past the limit, small and outgrown, then a document again
deep = []
cur = deep
100.times { n = []; cur << n; cur = n }
begin
  JSON.generate(deep)
rescue JSON::NestingError => e
  puts e.class
end
wide = ["w" * 700]
cur = wide
100.times { n = []; cur << n; cur = n }
begin
  JSON.generate(wide)
rescue JSON::NestingError => e
  puts e.class
end
puts JSON.generate({"after" => [1, "two", 3.0]})

# dump and pretty_generate on both sides of 512
puts JSON.dump({"n" => [Float::NAN, Float::INFINITY], "s" => "d" * 600}).size
puts JSON.dump([1, "two"])
puts JSON.pretty_generate({"a" => [1, {"b" => "c" * 520}], "e" => {}}).size
puts JSON.pretty_generate({"a" => [1, 2], "b" => {"c" => nil}})
