P = Struct.new(:name) do
  def bang = name << "!"
end
p1 = P.new(+"a")
p2 = P.new(p1.name)
p2.bang
p p1.name
