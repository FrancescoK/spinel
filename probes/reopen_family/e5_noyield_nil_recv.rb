class W
  def initialize(t) = @t = t
  def keep(x, memo) = (puts("#{@t}#{x}"); memo)
end
class Array
  def each_with_object(m) = (puts "mine"; m)
end
class H
  def initialize = (@w = nil; @arr = [3, 1])
  def put = @w = W.new("a")
  def run = p(@arr.each_with_object([], &@w.method(:keep)))
end
h = H.new
begin
  h.run
rescue NameError => e
  puts e.class
end
h.put
p h.run
