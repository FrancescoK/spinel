class Reg
  @@items = []
  def self.add(x) = (@@items << x)
  def self.items = @@items
  def self.bang_first = (@@items[0] << "!")
end
Reg.add(+"a")
Reg.add(Reg.items[0])
Reg.bang_first
p Reg.items
