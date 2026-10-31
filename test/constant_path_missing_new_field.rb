# A constant path that names nothing raises NameError at run time, and so
# does a field read or write on the object `.new` of it would have built:
# Holder::Pt is no member of Holder though Pt is defined at the top level
# (#10577), and the receiver of `.x` is the raise, which has to type as an
# object of Pt's class for the field access to compile.
module Holder; end
Pt = Struct.new(:x, :y)
Dt = Data.define(:a)
class Foo
  attr_accessor :a
  def initialize(a = 1) = @a = a
  def twice = @a * 2
end

def try
  p yield
rescue NameError => e
  puts "NameError: #{e.message}"
end

try { Holder::Pt.new(1, 2).x }
try { Holder::Pt.new(1, 2).y }
try { Holder::Dt.new(a: 3).a }
try { Holder::Foo.new.a }
try { Holder::Foo.new(4).twice }
try { Holder::Foo.new&.a }
try { Holder::Foo.new.a = 5 }
try { Holder::Foo.new.a += 1 }
try { Holder::Pt.new(1, 2).x = 3 }
try { Holder::Pt.new(1, 2).to_a }
try { Pt.new(1, 2).x }
try { Foo.new(4).twice }
