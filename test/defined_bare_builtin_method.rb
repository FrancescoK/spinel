# defined? of a bare call answers "method" for a builtin method self has:
# Object's, and Class's and Module's in a class or module body and in a
# class method.
p defined?(freeze), defined?(itself), defined?(instance_variable_get(:@m)), defined?(nosuch)

class Shape
  p defined?(freeze), defined?(itself), defined?(nosuch)
  p defined?(name), defined?(new), defined?(attr_accessor)
  def self.facts = [defined?(name), defined?(superclass), defined?(freeze)]
  def facts = [defined?(freeze), defined?(name), defined?(superclass)]
end

class Plain
  p defined?(private)
end

module Helpers
  p defined?(name), defined?(new), defined?(module_function), defined?(superclass)
end

p Shape.facts, Shape.new.facts
