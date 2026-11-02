# included: the hook gives the base a class-level ivar through class_eval
module Registry
  def self.included(b)
    b.class_eval do
      @items = []
      def self.add(x) = @items << x
      def self.items = @items
    end
  end
end
class A
  include Registry
  add 1
  add 2
end
p A.items
