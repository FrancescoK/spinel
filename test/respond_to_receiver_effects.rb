# respond_to? with an answer known at compile time still evaluates a
# receiver that runs code: a constructor (initialize runs), a dup
# (initialize_copy runs), a method call and a Struct instance each count
# once. A constant, a class literal, a local and a literal run nothing.
$log = []

class Foo
  def initialize = ($log << :init)
  def initialize_copy(other) = ($log << :copy)
  def bar = 1
end

Pt = Struct.new(:x) do
  def initialize(*) = ($log << :struct; super)
end

def make = ($log << :make; Foo.allocate)
def text = ($log << :text; "abc")

p Foo.new.respond_to?(:bar), $log
o = Foo.new
$log.clear
p o.dup.respond_to?(:bar), o.dup.respond_to?(:nope), $log
$log.clear
p make.respond_to?(:bar), text.respond_to?(:upcase), $log
$log.clear
p Pt.new(1).respond_to?(:x), $log
$log.clear
p [Foo.new.respond_to?(:bar), Foo.new.respond_to?(:nope)], $log
$log.clear

K = Foo.new
$log.clear
p K.respond_to?(:bar), Foo.respond_to?(:new), String.respond_to?(:new), Pt.respond_to?(:members)
p o.respond_to?(:bar), "s".respond_to?(:upcase), 1.respond_to?(:+), nil.respond_to?(:to_a), $log
