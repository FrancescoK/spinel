# A bare `new(...)` in a class method of an exception class with no
# initialize keeps its message, as `Klass.new(...)` and `self.new(...)` do.
class Plain < StandardError
  def self.build(text) = new(text)
  def self.bare = new
  def self.sym = new(:oops)
  def self.num = new(42)
end
class Sub < Plain; end

class WithIvar < StandardError
  attr_accessor :code
  def self.build(text, code)
    e = new(text)
    e.code = code
    e
  end
end

class Errno2 < Errno::ENOENT
  def self.build(path) = new(path)
end

module Outer
  class Inner < ArgumentError
    def self.build(text) = new(text)
  end
end

p Plain.build("x").message
p Plain.bare.message
p Plain.sym.message
p Plain.num.message
p Plain.build("x").class
p Sub.build("from sub").message
p Sub.build("from sub").class
e = WithIvar.build("with ivar", 7); p [e.message, e.code]
p Errno2.build("/nope").message
p Outer::Inner.build("nested").message
p Outer::Inner.build("nested").is_a?(ArgumentError)
begin
  raise Plain.build("raised")
rescue Plain => e
  p e.message
end
