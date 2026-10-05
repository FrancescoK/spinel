# activesupport gives every object a class_eval (Kernel#class_eval, through
# its singleton class). A class or module finds Module#class_eval first, so
# its string class_eval still defines into it -- the Kernel method is only
# what a plain object reaches.
module Kernel
  def class_eval(*args, &block)
    singleton_class.class_eval(*args, &block)
  end
end

module Conf
  class_eval "def self.level = 3", __FILE__, __LINE__
  class_eval <<~RUBY, __FILE__, __LINE__ + 1
    def self.label = "conf"
    def self.both = [level, label]
  RUBY
end

class Widget
  class_eval <<~RUBY, __FILE__, __LINE__ + 1
    def hello = "hi"
  RUBY
end

p Conf.level, Conf.label, Conf.both
p Widget.new.hello
