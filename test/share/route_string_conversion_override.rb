# spinel: share
# spinel: gc-minor
# A String override must run even when its receiver is a shared handle.
class String
  def to_s = +"override"
end
class Text
  def to_s = +"text"
end
s = +"source"
x = [s, Text.new][ARGV.size]
y = x.to_s
y << "!"
p [s, y]
