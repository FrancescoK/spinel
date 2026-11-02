class H
  def initialize = (@arr = [3, 1]; @t = "a")
  def keep(x, m) = (puts("#{@t}#{x}"); m)
  def run = p(@arr.each_with_object([], &method(:keep)))
end
class Array
  def each_with_object(m) = (each { |x| yield(x, m) }; m)
end
H.new.run
