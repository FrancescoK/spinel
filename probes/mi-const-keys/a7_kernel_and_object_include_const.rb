module Kernel
  KA = 42
end
class Q; def a = KA; end
p KA, Q.new.a
module GM; MC = :m; end
Object.include GM
p MC
