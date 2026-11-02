class Array
  def each_with_object(m) = (each { |x| yield(x, m) }; m)
end
class W
  def initialize(t) = @t = t
  def keep(x, m) = (m << "#{@t}#{x}" * 3; m)
end
class H
  def initialize = @arr = (1..50).to_a
  def run = @arr.each_with_object([], &W.new("w" + @arr.size.to_s).method(:keep)).size
end
s = 0
20.times { s += H.new.run }
p s
