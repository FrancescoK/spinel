# spinel: share
# This typed caller keeps the factory's inferred Hash narrow. The same factory
# initializes Bag, whose String values must preserve identity when shared.
def str_map
  Hash.new("")
end

def typed_map_caller
  map = str_map
  map["seed"] = "literal"
  map
end

class Bag
  attr_reader :headers

  def initialize
    @headers = str_map
  end

  def put(value)
    @headers["X-Trace"] = value
  end
end

typed = typed_map_caller
puts typed["seed"]
typed["extra"] = "written"
puts typed["extra"]

left = Bag.new
right = Bag.new
alias_headers = left.headers
value = String.new("before")
left.put(value)
value << "-after"
puts alias_headers.equal?(left.headers)
puts !left.headers.equal?(right.headers)
puts left.headers["X-Trace"].equal?(value)
puts left.headers["X-Trace"]
alias_headers["Alias"] = "visible"
puts left.headers["Alias"]
puts right.headers.empty?
puts alias_headers.default.equal?(left.headers.default)
puts alias_headers.default.frozen?
alias_headers.freeze
puts left.headers.frozen?
begin
  left.headers["Blocked"] = "no"
rescue FrozenError
  puts "frozen write rejected"
end
