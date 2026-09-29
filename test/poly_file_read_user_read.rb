# A File in a poly slot still reads itself when a user class owns `read`.
class Cell
  def initialize(v) = @v = v
  def read(type) = "#{type}:#{@v}"
end
path = __FILE__
src = [File.open(path, "rb"), Cell.new(3)].first
p src.read.lines.first.start_with?("# A File")
p Cell.new(4).read(:int)
