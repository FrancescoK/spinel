module M
  class Base
    def w = :base
  end
end
Al = M::Base
class Sub < Al
end
p Sub.new.w, Sub.superclass
