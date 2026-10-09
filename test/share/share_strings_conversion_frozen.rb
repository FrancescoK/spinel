# spinel: share
# spinel: gc-minor
class BorrowedText < StandardError
  def to_s = "frozen"
end
class FreshText
  def to_s = +"fresh"
end
x = [BorrowedText.new, FreshText.new][ARGV.size]
a = x.to_s
b = x.to_s
begin
  a << "!"
rescue FrozenError
end
p a.equal?(b), a, b
p a.equal?("frozen"), "frozen".equal?(a), a.frozen?
