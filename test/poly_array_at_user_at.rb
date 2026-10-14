# Array#at on an Array of mixed elements, in a program whose own class
# defines `at` too (so desugar_array_at keeps the name): the index read
# [] makes, not a NoMethodError.

class Sub
  def initialize = @e = [1, "x", :y]
  def at(i) = @e.at(i)
  def at_all(*args, &block) = @e.at(*args, &block)
end

s = Sub.new
p s.at(1), s.at(-1), s.at(5), s.at(1.9)
p s.at_all(2)
[nil, "1"].each do |i|
  begin
    s.at(i)
  rescue TypeError => e
    p e.message
  end
end
