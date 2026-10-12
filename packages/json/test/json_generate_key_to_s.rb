# spinel: int64
require "json"
# An object key that is not a String, Symbol or Integer generates as its
# #to_s, as CRuby's json does.
class P
  def to_s = "pp"
end
class Plain; end
class KP < String; end

puts JSON.generate({1.5 => 1, nil => 2, [1, 2] => 3, P.new => 4, :s => 5, 7 => 6, true => 7})
puts JSON.pretty_generate({2.0 => [1], [:a] => {nil => "n"}})
puts({1.25 => "q"}.to_json)
puts JSON.generate({KP.new("kp") => 2, "lit" => 3})
s = +"a"
s << "b"
puts JSON.generate({s => 1})
puts JSON.generate({Plain.new => 1}).sub(/0x\h+/, "0x")
puts JSON.generate({(2**40) => "big", -3 => "neg"})

# a key's own #to_s that raises leaves the walk cleanly
class Boom
  def initialize(ok) = @ok = ok
  def to_s
    raise ArgumentError, "boom" unless @ok
    "fine"
  end
end
3.times do
  begin
    JSON.generate({"a" => "x" * 50, Boom.new(false) => 1})
  rescue ArgumentError => e
    puts e.message
  end
end
puts JSON.generate({Boom.new(true) => 1})

# a key's #to_s that empties the Hash being generated ends the walk there
class Clearing
  def initialize(h, name)
    @h = h
    @name = name
  end
  def to_s
    @h.clear
    GC.start
    @name
  end
end
h = {}
h[Clearing.new(h, "k1")] = "v" * 40
h[Clearing.new(h, "k2")] = [1, 2]
h[Clearing.new(h, "k3")] = {"x" => "y"}
puts JSON.generate(h)
h2 = {}
h2[Clearing.new(h2, "p1")] = [1]
h2[Clearing.new(h2, "p2")] = 2
puts JSON.pretty_generate(h2)
