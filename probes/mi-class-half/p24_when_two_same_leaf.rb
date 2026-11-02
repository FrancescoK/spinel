module A; class Node; end; end
module B; class Node; end; end
def k(x)
  case x
  when A::Node then :a
  when B::Node then :b
  end
end
p k(B::Node.new), k(A::Node.new), B::Node.new.is_a?(A::Node)
