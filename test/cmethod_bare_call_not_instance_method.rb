# A bare call in a class method is sent to the class: the class's own
# instance method of the name (one an included module gives it, too) is
# not the class's, so the call is the class's NameError.
module Layout
  def self.included(base) = base.extend(ClassMethods)
  module ClassMethods
    def check = (_layout == true)
  end
  def _layout(a, b, c) = :instance
end
class Base
  include Layout
  def self.go = name_of
  def name_of = "instance"
end
module Kernel
  def kern_m = "kern_m"
end
class Base
  def self.kern = kern_m
end
begin
  Base.check
rescue NameError
  puts "NameError check"
end
begin
  Base.go
rescue NameError
  puts "NameError go"
end
puts Base.kern
puts Base.new._layout(1, 2, 3)
