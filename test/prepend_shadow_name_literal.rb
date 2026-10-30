# A method the program names with the prefix of a prepend copy's hidden name
# (`__prep <n> <name>`) or of an include copy's (`__inc <n> <name>`) but not
# its whole spelling is the program's own: the name queries, send and the
# method lists answer it.
class Lit
  define_method(:"__prep foo") { 1 }
  define_method(:"__prep") { 2 }
  define_method(:"__prep ") { 3 }
  define_method(:"__prep 0") { 4 }
  define_method(:"__prep 0 ") { 5 }
  define_method(:"__prep x 1") { 6 }
  define_method(:"__inc foo") { 7 }
  define_method(:"__inc 0 ") { 8 }
  define_method(:"__inc x 1") { 10 }
  def plain = 9
end

o = Lit.new
p Lit.instance_methods(false).sort
p o.public_methods(false).sort
p [:"__prep foo", Lit.method_defined?(:"__prep foo"), Lit.public_method_defined?(:"__prep foo"), o.respond_to?(:"__prep foo"),
   o.send(:"__prep foo"), o.public_send(:"__prep foo"), o.__send__(:"__prep foo"), o.method(:"__prep foo").call]
p [:"__prep", Lit.method_defined?(:"__prep"), Lit.public_method_defined?(:"__prep"), o.respond_to?(:"__prep"),
   o.send(:"__prep"), o.public_send(:"__prep"), o.__send__(:"__prep"), o.method(:"__prep").call]
p [:"__prep ", Lit.method_defined?(:"__prep "), Lit.public_method_defined?(:"__prep "), o.respond_to?(:"__prep "),
   o.send(:"__prep "), o.public_send(:"__prep "), o.__send__(:"__prep "), o.method(:"__prep ").call]
p [:"__prep 0", Lit.method_defined?(:"__prep 0"), Lit.public_method_defined?(:"__prep 0"), o.respond_to?(:"__prep 0"),
   o.send(:"__prep 0"), o.public_send(:"__prep 0"), o.__send__(:"__prep 0"), o.method(:"__prep 0").call]
p [:"__prep 0 ", Lit.method_defined?(:"__prep 0 "), Lit.public_method_defined?(:"__prep 0 "), o.respond_to?(:"__prep 0 "),
   o.send(:"__prep 0 "), o.public_send(:"__prep 0 "), o.__send__(:"__prep 0 "), o.method(:"__prep 0 ").call]
p [:"__prep x 1", Lit.method_defined?(:"__prep x 1"), Lit.public_method_defined?(:"__prep x 1"), o.respond_to?(:"__prep x 1"),
   o.send(:"__prep x 1"), o.public_send(:"__prep x 1"), o.__send__(:"__prep x 1"), o.method(:"__prep x 1").call]
p [:"__inc foo", Lit.method_defined?(:"__inc foo"), Lit.public_method_defined?(:"__inc foo"), o.respond_to?(:"__inc foo"),
   o.send(:"__inc foo"), o.public_send(:"__inc foo"), o.__send__(:"__inc foo"), o.method(:"__inc foo").call]
p [:"__inc 0 ", Lit.method_defined?(:"__inc 0 "), Lit.public_method_defined?(:"__inc 0 "), o.respond_to?(:"__inc 0 "),
   o.send(:"__inc 0 "), o.public_send(:"__inc 0 "), o.__send__(:"__inc 0 "), o.method(:"__inc 0 ").call]
p [:"__inc x 1", Lit.method_defined?(:"__inc x 1"), Lit.public_method_defined?(:"__inc x 1"), o.respond_to?(:"__inc x 1"),
   o.send(:"__inc x 1"), o.public_send(:"__inc x 1"), o.__send__(:"__inc x 1"), o.method(:"__inc x 1").call]

# a prepend over a method of the same class still hides its copy
module Loud
  def speak = "L " + super
end
class Pre
  define_method(:"__prep foo") { 1 }
  def speak = "hi"
  prepend Loud
end
q = Pre.new
p q.speak
p Pre.instance_methods(false).sort
p Pre.method_defined?(:"__prep foo")
p Pre.method_defined?(:"__prep 0 speak")
p q.respond_to?(:"__prep 0 speak")
begin
  q.send(:"__prep 0 speak")
rescue NoMethodError => e
  puts e.class
end

# an include's hidden copy of a module method (`__inc <n> <name>`) is hidden too
module Base
  def hello = "base"
end
class Inc
  define_method(:"__inc foo") { 1 }
  include Base
  def hello = "own " + super
end
r = Inc.new
p r.hello
p Inc.instance_methods(false).sort
p Inc.method_defined?(:"__inc foo")
p Inc.method_defined?(:"__inc 0 hello")
p r.respond_to?(:"__inc 0 hello")
