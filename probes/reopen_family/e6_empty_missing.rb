class W
  def keep(x, memo) = memo
end
class Array
  def each_with_object(m) = (each { |x| yield(x, m) }; m)
end
class H
  def initialize = (@w = W.new; @arr = [])
  def run = p(@arr.each_with_object([], &@w.method(:nope)))
end
begin
  H.new.run
rescue NameError => e
  puts e.class
end
