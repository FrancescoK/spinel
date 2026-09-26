# `extend self` is the other spelling of module_function: every method of the
# module is callable on the module itself. Unlike module_function's bare form
# the placement carries no meaning -- it applies to the whole body, before and
# after -- and the methods stay callable as instance methods when the module
# is included.
module Fmt
  extend self

  def upcase_all(xs) = xs.map { |x| x.upcase }

  def join(xs, sep = ", ") = upcase_all(xs).join(sep)
end

p Fmt.upcase_all(["a", "b"])
p Fmt.join(["a", "b"])
p Fmt.join(["a", "b"], "-")

# the marker below the defs it governs
module Rev
  def twice(s) = s + s
  extend self
end
p Rev.twice("ab")
# `extend self` in a module body: every instance method the module defines
# is also callable on the module itself, exactly as `module_function`
# makes it, and unlike module_function the instance copies stay public.
# activesupport's Inflector is this shape (`Inflector.underscore(name)`
# from its autoloader); Spinel refused the module-level call.
module Inflector
  extend self

  def underscore(s) = s.gsub(/([A-Z])/) { "_" + $1.downcase }.sub(/\A_/, "")
  def camel(s) = s.split("_").map(&:capitalize).join
  def both(s) = [underscore(s), camel(underscore(s))]

  def self.explicit = "explicit"
end

module Later
  def greet(n) = "hi #{n}"
  extend self
end

class User
  include Inflector
  def show(s) = underscore(s)
  def via_module(s) = Inflector.camel(s)
end

p Inflector.underscore("FooBar")
p Inflector.camel("foo_bar")
p Inflector.both("AbCd")
p Inflector.explicit
p Later.greet("x")
u = User.new
p u.show("XyZ")
p u.via_module("a_b")
p u.underscore("Pq")
