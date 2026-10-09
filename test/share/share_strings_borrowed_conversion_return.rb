# spinel: share
# spinel: gc-minor
# A borrowing user conversion cannot be replaced by a fresh String.
class BorrowedText
  def to_s = $source.to_s
end
$source = +"source"
x = [BorrowedText.new, 1][ARGV.size]
y = x.to_s
y << "!"
p [$source, y]
$source << "?"
p y
