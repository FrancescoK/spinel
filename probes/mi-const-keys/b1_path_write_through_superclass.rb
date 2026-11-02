module Outer
  class Base; end
end
class Sub < Outer::Base; end
Outer::Base::LIMIT = 8
LIMIT = 1
p Sub::LIMIT
class Base2; end
class Sub2 < Base2; end
Base2::LIM = 3
LIM = 4
p Sub2::LIM
