# A class whose to_s answers itself and which defines the in-place String
# methods (Active Support's SafeBuffer): a value that may be it or a String
# reaches a class dispatch for gsub! and insert, whose builtin arm must
# still change the variable that holds a plain String.
class Buffer
  def initialize(s) = @s = s
  def to_s = self
  def gsub!(*) = self
  def insert(*) = self
  def size = @s.size
  def inspect = "#<Buffer #{@s}>"
end

def delimited(number)
  left = number.to_s
  position = left.size - 3
  while position > 0
    left.insert(position, ",")
    position -= 3
  end
  left
end

def grouped(term)
  string = term.to_s
  r = string.gsub!(/(\d)(?=(\d{3})+$)/) { "#{$1}_" }
  puts "#{string.inspect} r=#{r.inspect}"
  string
end

class Holder
  def initialize(number)
    @left = number.to_s
  end
  def delimit
    @left.insert(-4, ",")
    @left.gsub!(/^(\d)/) { "#{$1}." }
    @left
  end
end

p delimited(1234567)
p delimited(Buffer.new("12345678"))
p grouped(1234567)
p grouped(Buffer.new("12"))
p Holder.new(1234567).delimit
p Holder.new(Buffer.new("1")).delimit
