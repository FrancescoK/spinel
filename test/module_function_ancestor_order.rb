# A receiverless call to a module_function that several ancestors could
# answer runs the one that comes first in the ancestor order: a module the
# class includes before one its superclass includes, the last of two
# includes, a module before the modules it includes, and a module the class
# includes before a method its superclass defines.
module Older
  module_function
  def tag = "older"
end

module Newer
  module_function
  def tag = "newer"
end

class Base
  include Older
end

class Child < Base
  include Newer
  def show = tag
end

class Both
  include Older
  include Newer
  def show = tag
end

module Inner
  module_function
  def tag = "inner"
end

module Outer
  include Inner
  module_function
  def tag = "outer"
end

class Box
  include Outer
  def show = tag
end

class Plain
  def tag = "plain"
end

class Wrapped < Plain
  include Newer
  def show = tag
end

class Kept < Plain
  def show = tag
end

p Child.new.show, Both.new.show, Box.new.show, Wrapped.new.show, Kept.new.show
