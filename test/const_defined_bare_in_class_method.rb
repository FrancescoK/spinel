# A bare `const_defined?` with a literal name, in a class method or a
# class body, asks the class, as a bare `const_get` already does.

module Verbs
  GET = 1
  HAS_GET = const_defined?(:GET)
  HAS_POST = const_defined?(:POST)
  def self.get? = const_defined?(:GET)
  def self.post? = const_defined?(:POST)
end

p Verbs.get?
p Verbs.post?
p Verbs::HAS_GET
p Verbs::HAS_POST

class Base
  A = 1
  def self.a? = const_defined?(:A)
end

class Sub < Base
end

p Sub.a?
