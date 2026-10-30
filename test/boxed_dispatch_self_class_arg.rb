# A boxed receiver's call passing `self` from a class method: the
# class-id dispatch's builtin fallback arm spells self as the method's
# `_sp_cls` parameter, and the arm region hoisted into a function of its
# own could not see it (an undeclared identifier in the C).
class Base
  def self.descendants = (ARGV.empty? ? Chain.new : [1, 2])
  def self.attach
    descendants.prepend(self).each do |target|
      p target
    end
  end
end
class Sub < Base; end
class Chain
  def initialize; @items = []; end
  def prepend(*cbs); @items.unshift(*cbs); self; end
  def each(&b) = @items.each(&b)
end
Sub.attach
Base.attach
