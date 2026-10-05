class Box
  def initialize = (@s = +"q")
  def text = @s
end
k = Box.new
@h = {}
@h[:a] = k.text
@h[:a].upcase!
p k.text, @h
