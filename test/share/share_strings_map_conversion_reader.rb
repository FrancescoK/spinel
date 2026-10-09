# spinel: gc-minor
# An element read from a temporary map carries the block result's handle,
# including a boxed String's to_s and an exception's stored message.
def append_text(text)
  text << "!"
end
symbols = [:one, :two]
p append_text(symbols.map(&:to_s)[0])
p append_text(symbols.collect { |symbol| symbol.to_s }.fetch(1))
p symbols

text = +"held"
values = [text, 1]
append_text(values.map(&:to_s)[0])
p text
append_text(values.collect { |value| value.to_s }.fetch(0))
p text

message = +"message"
exceptions = [RuntimeError.new(message), 1]
append_text(exceptions.map(&:to_s).first)
p message

p append_text([1, 2].map { |value| value.to_s }[0])
p append_text(values.map { |value| value.to_s + "?" }[0])
p text
