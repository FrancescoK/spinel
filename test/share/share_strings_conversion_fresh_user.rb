# A boxed conversion keeps a String receiver's handle beside user methods
# that answer fresh Strings. Each receiver and override runs once.
class FreshText
  def to_s
    $calls += 1
    +"fresh"
  end
end
class FrozenText
  def to_s = "iced"
end
$calls = 0
s = +"source"
x = [s, FreshText.new][ARGV.size]
y = x.to_s
y << "!"
p [s, y, s.equal?(y)]

def convert(value)
  text = value.to_s
  begin
    text << "!"
  rescue FrozenError
    puts "frozen"
  end
  text
end
p convert(nil), convert(42), convert(FreshText.new), convert(FrozenText.new)
p $calls

# The same conversion can be an element or a method argument.
values = [x.to_s]
values[0] << "?"
p s
def grow(value)
  value << "+"
  nil
end
grow(x.to_s)
p s

# A temporary receiver survives the fresh-return call's allocations.
$receivers = 0
def receiver
  $receivers += 1
  [FreshText.new, nil][ARGV.size]
end
text = receiver.to_s
text << "."
p text, $receivers, $calls

# Fresh-return facts also admit nil, which must stay nil through the route.
class MaybeText
  def to_s = ARGV.empty? ? nil : +"fresh"
end
maybe = [MaybeText.new, s][ARGV.size]
begin
  maybe.to_s << "!"
rescue NoMethodError
  puts "nil result"
end
p maybe.to_s

# Exception#to_s keeps the message's handle, including through a subclass.
class PlainError < StandardError
end
message = +"problem"
error = RuntimeError.new(message)
boxed = [error, FreshText.new][ARGV.size]
answer = boxed.to_s
answer << "!"
p [message, error.message, message.equal?(answer)]
child = PlainError.new(+"child")
boxed_child = [child, FreshText.new][ARGV.size]
child_answer = boxed_child.to_s
child_answer << "?"
p child.message
