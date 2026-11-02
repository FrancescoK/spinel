# included: hook defined after the include in the same class body's module reopened inside the class
module M; end
class A
  include M
  module ::M
    def self.included(b) = puts("inc #{b}")
  end
  include M
end
