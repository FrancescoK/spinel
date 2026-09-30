# An include at the top level adds the module to Object. An instance of a
# BasicObject subclass is not an Object, so a bare call in its instance
# method does not reach the module: CRuby raises NoMethodError. Spinel
# resolved the call to the module's method and ran it (a silent wrong answer).
# Written with parentheses, the call is now refused at this line, as any bare
# call to a method the receiver does not have is. The parenless spelling is
# CRuby's runtime NameError, which Spinel raises the same way
# (test/basicobject_toplevel_include_class_method.rb).
module T
  module_function

  def hello = "hi"
end

include T

class Blank < BasicObject
  def greet = hello()
end

$stdout.puts Blank.new.greet
