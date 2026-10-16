# method_defined? and its kin answer a builtin class's or module's own
# methods as CRuby does (src/core_class_methods.inc, from
# tools/gen_method_names.rb): on the class itself, in a reopened body, on a
# class of the program below a builtin one, and in a polyfill's condition.

class String
  def shout = upcase + "!"
  p method_defined?(:upcase), method_defined?(:shout), method_defined?(:nope)
  p self.method_defined?(:upcase), private_method_defined?(:puts), public_method_defined?(:puts)
  p method_defined?(:upcase, false), method_defined?(:between?, false), method_defined?(:between?)
end
class ::String
  p method_defined?(:upcase), method_defined?(:shout)
end
module Comparable
  p method_defined?(:clamp), method_defined?(:inspect)
end
class Array
  p protected_method_defined?(:each), method_defined?(:each_slice)
end
class String
  def whisper = downcase
  private :whisper
end
p String.method_defined?(:whisper), String.private_method_defined?(:whisper), String.method_defined?(:shout)
p Kernel.private_method_defined?(:puts), Kernel.method_defined?(:puts), Integer.method_defined?(:times)
p ArgumentError.method_defined?(:message), Hash.method_defined?(:fetch, false), Hash.method_defined?(:map, false)
p Random.method_defined?(:hex) rescue p $!

# a class of the program answers the builtin methods above it
class MyErr < StandardError; end
class Foo; def a; end; end
class Arr < Array; end
module M; def mm; end; end
p MyErr.method_defined?(:message), Foo.method_defined?(:inspect), Foo.method_defined?(:frozen?), Foo.method_defined?(:instance_variable_get)
p Arr.method_defined?(:each), Foo.private_method_defined?(:puts), Foo.method_defined?(:then)
p M.method_defined?(:mm), M.method_defined?(:inspect)

# a polyfill does not replace a method the builtin has
class String
  unless method_defined?(:upcase)
    def upcase = "polyfill"
  end
  def squish = strip.squeeze(" ") unless method_defined?(:squish)
end
class Array
  def second = self[1] unless method_defined?(:second)
  if !self.method_defined?(:first)
    def first = :mine
  end
end
module Kernel
  def then = :mine unless method_defined?(:then)
end
p "ab".upcase, " a  b ".squish, [1, 2].second, [1, 2].first, 3.then { _1 + 1 }
