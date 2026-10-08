# A fresh builtin inspect arm does not make a borrowing user arm fresh.
class BorrowedInspection
  def initialize(text) = @text = text
  def inspect = @text
end
source = +"source"
x = [BorrowedInspection.new(source), 1][ARGV.size]
y = x.inspect
y << "!"
p [source, y, source.equal?(y)]
