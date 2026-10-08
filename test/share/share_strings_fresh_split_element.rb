# A boxed String's split and scan still create new String elements.
def split_piece(value, index)
  original = value
  value = value.split(" ", 2)[index]
  value << "!"
  p [original, value]
end
split_piece(+"one two", 0)
split_piece(+"three four", 1)
begin
  split_piece(nil, 0)
rescue NoMethodError
  puts "nil receiver"
end

def scan_piece(value)
  original = value
  value = value.scan(/\w+/).first
  value << "?"
  p [original, value]
end
scan_piece(+"five six")
begin
  scan_piece(nil)
rescue NoMethodError
  puts "nil receiver"
end

# A user split's elements can still belong to another name.
class Pieces
  def initialize(text) = @text = text
  def split = [@text]
end
source = +"borrowed"
answer = Pieces.new(source).split[0]
answer << "?"
p [source, answer, source.equal?(answer)]
