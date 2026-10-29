# The class_eval text of a Class.new or Module.new block is grafted into the
# class body the block becomes, and lowered as that body's own code.

k = Class.new do
  class_eval "def x; 1; end"
end
p k.new.x

Named = Class.new do
  class_eval "def x; 2; end"
end
p Named.new.x

Mixin = Module.new do
  module_eval "def mx; 3; end"
end
class UsesMixin
  include Mixin
end
p UsesMixin.new.mx

class Base
  def base; :base; end
end
Sub = Class.new(Base) do
  class_eval "def y; 4; end"
end
p Sub.new.y, Sub.new.base

Doc = Class.new do
  class_eval <<~RUBY
    def h; "heredoc"; end
  RUBY
end
p Doc.new.h

Many = Class.new do
  class_eval "def a1; 1; end; def a2; 2; end; attr_accessor :v"
end
o = Many.new
o.v = 9
p [o.a1, o.a2, o.v]

class Outer
  INNER = Class.new do
    class_eval "def z; :z; end"
  end
end
p Outer::INNER.new.z

Wrap = Class.new do
  Wrapped = Class.new do
    class_eval "def i; :inner; end"
  end
  class_eval "def o; :outer; end"
end
p Wrap.new.o, Wrapped.new.i

Listed = Class.new do
  %w(la lb).each do |n|
    class_eval "def #{n}; :#{n}; end"
  end
end
p Listed.new.la, Listed.new.lb

module Plain; end
WithInclude = Class.new do
  include Plain
  module_eval "def wi; :wi; end"
end
p WithInclude.new.wi, WithInclude.include?(Plain)

module Hooked
  def self.included(base)
    base.class_eval "def hooked; :hooked; end"
  end
end
HookedUser = Class.new do
  include Hooked
end
p HookedUser.new.hooked

module HookedBlock
  def self.included(base)
    base.class_eval do
      class_eval "def hooked_block; :hooked_block; end"
    end
  end
end
HookedBlockUser = Class.new do
  include HookedBlock
end
p HookedBlockUser.new.hooked_block

# the grafted text is lowered as the class body's own code is
Shown = Class.new do
  class_eval "def inspect(i = 0); \"shown\"; end"
end
p Shown.new

Rescuing = Class.new do
  class_eval "def r; [1].map do |v| Integer('z'); rescue ArgumentError; v + 1; end; end"
end
p Rescuing.new.r
