# spinel: share
# spinel: gc-minor
# Text built from an exception whose class is a Class.new class shows the class
# as Ruby does: #<Class:0x...> while it has no constant, its constant after,
# and no "(Class)" suffix on detailed_message for the unnamed form.
def mask(s) = s.to_s.gsub(/0x\h+/, "0xX")
k = Class.new(StandardError)
begin
  raise k, "boom"
rescue => e
  c = e.class
  p mask(e.inspect), mask([e].inspect), mask(e.detailed_message)
  p mask([c].inspect), mask({c => 1}.inspect), mask("#{c}")
  p mask(c.to_s), c.name
end
p mask(k.new.message), mask(k.new("m").inspect)

class Plain < StandardError; end
begin
  raise Plain, "named"
rescue => e
  p e.inspect, e.detailed_message, [e.class]
end

Foo = k
begin
  raise k, "later"
rescue => e
  p e.inspect, [e].inspect, e.detailed_message, [e.class], e.message
end

# a poly value's class after a round trip
late = Class.new { attr_accessor :a }
LateData = late
o = late.new
o.a = 1
x = Marshal.load(Marshal.dump(o))
p x.class, [x.class], "#{x.class}"

# NoMethodError names an instance of a Class.new class as Ruby does, for a
# receiver the compiler types as that class
j = Class.new { def hi = 1; def pub = hidden; private def hidden = 2; protected def prot = 3 }
jo = j.new
begin
  jo.nope
rescue NoMethodError => e
  puts mask(e.message)
end
begin
  j.new.nope(1, 2)
rescue NoMethodError => e
  puts mask(e.message)
end
begin
  jo.hidden
rescue NoMethodError => e
  puts mask(e.message)
end
begin
  jo.prot
rescue NoMethodError => e
  puts mask(e.message)
end
LateJ = j
begin
  j.new.nope
rescue NoMethodError => e
  puts mask(e.message)
end
begin
  j.new.hidden
rescue NoMethodError => e
  puts mask(e.message)
end

# a bare unknown name inside the class's own method is a NameError naming it
vk = Class.new { def c = nope4 }
begin
  vk.new.c
rescue NameError => e
  puts mask(e.message)
end
VNamed = vk
begin
  vk.new.c
rescue NameError => e
  puts mask(e.message)
end
