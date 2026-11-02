module Ma; def hi = :a; end
module Mb; def hi = :b; end
module X
  Mix = Ma
  class K; include Mix; end
end
module Y
  Mix = Mb
  class K; include Mix; end
end
p X::K.new.hi, Y::K.new.hi
