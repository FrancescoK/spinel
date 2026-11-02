module A; class Node; end; end; module B; class Node; end; end; x = B::Node.new; p(case x when A::Node then :a when B::Node then :b end)
