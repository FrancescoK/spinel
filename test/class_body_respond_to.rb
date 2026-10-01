# respond_to? on a class object, from its class body (self is the class) and
# from outside: Class's and Module's own methods, public and private
class Proxy
  def method_missing(name, *args) = name
  # rack's BodyProxy: the call is skipped where the shim is not there
  ruby2_keywords(:method_missing) if respond_to?(:ruby2_keywords, true)
  p respond_to?(:new), respond_to?(:nope), respond_to?(:attr_reader)
  p respond_to?(:private), respond_to?(:private, true), respond_to?(:inherited, true)
  p respond_to?(:module_function, true)
end

module Helpers
  p respond_to?(:module_function, true), respond_to?(:new), respond_to?(:superclass)
  p respond_to?(:attr_accessor), respond_to?(:include?)
end

p Proxy.respond_to?(:attr_reader), Proxy.respond_to?(:subclasses), Proxy.respond_to?(:private)
p Proxy.respond_to?(:private, true), Proxy.respond_to?(:const_missing)
p Helpers.respond_to?(:superclass), Helpers.respond_to?(:allocate), Helpers.respond_to?(:refine, true)
p Comparable.respond_to?(:superclass), Comparable.respond_to?(:attr_reader), Range.respond_to?(:subclasses)
