require "json"
# A String's NUL bytes are part of it: JSON.generate writes each as \u0000
# and goes on to the String's end, as CRuby's json does, rather than stopping
# at the first one.

puts JSON.generate(["a\0b"])
puts JSON.generate({"b" => "\0x"})
puts "a\0b".to_json
puts JSON.generate({"k\0" => "\x01\0\x1f"})
puts JSON.pretty_generate({"a\0" => ["x\0y"]})
puts JSON.dump(["a\0b"])
puts JSON.generate([:sym, "plain", "é\0é", nil, 1])

# a String changed in place, as a value and as a key
s = +"a"
s << "\0b"
puts JSON.generate([s, {s => s}])

# a String subclass instance, held as its handle
class Tag < String; end
puts JSON.generate([Tag.new("t\0u")])

# a parsed one round-trips
x = JSON.parse('{"q":"z\u0000z"}')
puts JSON.generate(x)
puts JSON.parse(JSON.generate(["a\0b"]))[0] == "a\0b"

# past the walk's stack buffer
long = ("ab\0" * 400)
out = JSON.generate([long])
puts out.length
puts JSON.parse(out)[0] == long

# an object's #to_s, as a value and as a key
class Foo
  def to_s = "f\0g"
end
puts JSON.generate([Foo.new])
puts JSON.generate({Foo.new => 1})
puts JSON.pretty_generate([Foo.new])
