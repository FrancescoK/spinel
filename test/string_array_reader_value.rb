# A reader method answers its ivar's String itself, so the pushed element is
# @s and an append through the element changes @s. The element is a copy
# today: refused.
class C
  def initialize = (@s = +"a")
  def sb = @s
  def go
    a = []
    a << sb
    a[0] << "!"
    @s
  end
end
p C.new.go
