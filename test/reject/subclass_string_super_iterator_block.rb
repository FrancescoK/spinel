# A `super` into String with no block of its own passes the method's block
# on, and a String iterator does not take a block argument yet: refused,
# where the block used to be dropped (the override printed "x" alone).
class Buf < String
  def each_char
    puts "x"
    super
  end
end
Buf.new("ab").each_char { |ch| p ch }
