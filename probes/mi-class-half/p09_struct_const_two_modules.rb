module A
  Pt = Struct.new(:x)
end
module B
  Pt = Struct.new(:y)
end
p A::Pt.new(1).x
p B::Pt.new(2).y
p A::Pt.members, B::Pt.members
