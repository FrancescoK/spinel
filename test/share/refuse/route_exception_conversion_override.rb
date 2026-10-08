# An exception's override must run instead of reading its stored message.
module Text
  def to_s = +"override"
end
class Error < StandardError
  include Text
end
class FreshText
  def to_s = +"fresh"
end
x = [Error.new("message"), FreshText.new][ARGV.size]
y = x.to_s
y << "!"
p y
