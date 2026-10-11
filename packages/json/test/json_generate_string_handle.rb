require "json"
# A String held as a handle -- an instance of a String subclass, or a String
# the program changes in place -- is a JSON string of its bytes, as a String
# literal is; a String subclass with its own #to_json answers that.

class FD < String
  def initialize(s, name)
    super(s)
    @name = name
  end
  attr_reader :name
end
class Sub < FD; end
class ToS < String
  def to_s = "not this"
end
class Own < String
  def to_json(*a) = '"own"'
end

v = FD.new("stan", "name")
puts JSON.generate({"name" => v})
puts JSON.generate([v, "x", 1])
puts({"n" => v}.to_json)
puts v.to_json
puts JSON.generate(v)
puts JSON.generate([Sub.new("sub \"q\"\n", "n"), ToS.new("tos")])
puts JSON.pretty_generate({"a" => [v, ToS.new("t")], "b" => Own.new("x")})
puts JSON.generate([Own.new("x"), [Own.new("y")], {"o" => Own.new("z")}])
v << "!"
puts JSON.generate([v])
w = FD.new("", "e")
puts JSON.generate({"e" => w})

# A String changed in place
s = +"a"
s << "b"
puts JSON.generate([s, {"k" => s}])
puts s.to_json
t = String.new("x")
t.concat("y")
puts JSON.pretty_generate({"t" => t})
puts JSON.parse(JSON.generate([v, s]))[0]

# many of them, so the collector runs mid-walk
big = []
2000.times { |i| big << FD.new("v#{i}", "n") }
out = JSON.generate(big)
puts out.length
puts JSON.parse(out)[1999]

# beside a class of the program's own in one slot
class P
  def to_s = "p"
end
def pick(i) = i.even? ? ToS.new("tos") : P.new
puts JSON.generate([pick(0), pick(1)])
puts pick(0).to_json
