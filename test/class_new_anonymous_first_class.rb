# spinel: share
# spinel: gc-minor
# A Class.new class declared first must not make builtin classes that carry only
# their name (an exception's class, Range#class, Random#class) print as it does,
# and an unnamed class cannot be dumped.
k = Class.new { def hi = 1 }
p k.new.hi
begin
  raise ArgumentError, "x"
rescue => e
  p e.class.name, e.class.to_s, e.class, e.class.inspect
  puts "#{e.class}"
  puts e.class
end
r = ("a".."c")
p r.class.name, r.class.to_s
puts r.class
p Random.new(1).class.name

# two anonymous exception classes stay distinct, and rescue picks by identity
E = Class.new(StandardError)
j = Class.new(StandardError)
begin
  raise j
rescue => e
  p e.class.name, e.class == E, e.class == j
end
begin
  raise E
rescue j
  p :wrong
rescue E
  p :right
end

# Marshal: an unnamed class is refused, a named one round-trips
begin
  Marshal.dump(Class.new.new)
rescue TypeError => e
  puts e.message.sub(/0x\h+/, "0xX")
end
NamedDump = Class.new { attr_accessor :a }
o = NamedDump.new
o.a = 3
p Marshal.load(Marshal.dump(o)).a
late = Class.new { attr_accessor :b }
begin
  Marshal.dump(late.new)
rescue TypeError => e
  puts e.message.sub(/0x\h+/, "0xX")
end
LateName = late
q = late.new
q.b = 5
p Marshal.load(Marshal.dump(q)).b
