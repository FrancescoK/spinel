# included: the hook extends the base with class methods and defines an instance method
module M
  module ClassMethods
    def cm = "cm"
  end
  def self.included(b)
    b.extend(ClassMethods)
    b.class_eval { def im = "im" }
  end
end
class A; include M; end
puts A.cm, A.new.im
