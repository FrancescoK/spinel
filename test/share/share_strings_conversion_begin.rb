# A begin's result keeps the handle of a receiver-returning String conversion.
# A boxed conversion still runs a user method when that receiver owns to_s.
class FreshLabel
  attr_reader :calls
  def initialize
    @calls = 0
  end
  def to_s
    @calls += 1
    "label".dup
  end
end

label = FreshLabel.new
source = +"a\0b"
boxed = [source, label][0]
text = begin
  boxed.to_s
ensure
  100.times { "garbage" * 100 }
end
text << "x" * 100
p [source.size, text.size, source[0, 3]]
p text.equal?(source)

# The conditional containing map lowers through a begin too.
input = [source, ["a", "b"], label][0]
conditional = input.is_a?(Array) ? input.map { |v| v.to_s }.join(", ") : input.to_s
conditional << "!"
p [source.size, conditional.size]

plain = +"typed"
converted = begin
  plain.to_str
end
converted << "!"
p plain

rescued = begin
  raise "take rescue"
rescue RuntimeError
  plain.to_s
end
rescued << "?"
p plain

other = [label, source][0]
fresh = begin
  other.to_s
end
fresh << "!"
p [fresh, label.calls]

frozen_value = ["fixed", label][0]
fixed = begin
  frozen_value.to_s
end
begin
  fixed << "!"
rescue FrozenError
  p fixed
end

nothing = [nil, label, source][0]
empty = begin
  nothing.to_s
end
p empty
