# A `@v ||= ...` or `@w &&= ...` outside initialize writes the object, so the
# class cannot be a by-value struct: the write landed on the method's copy and
# the memo was computed again on every call.

class K
  def initialize; @n = 3; end
  def v = (@v ||= begin; puts "computing"; @n * 2; end)
  def w = (@w &&= 1)
end
k = K.new
p k.v, k.v
p k.w

class Name
  def initialize(first) = (@first = first)
  def label = (@label ||= begin; puts "building"; "<#{@first}>"; end)
end
n = Name.new("ada")
p n.label
p n.label
