# The load record holds a mixin or an attr form inside an instance_eval
# block on a class as the class's own: self is the class there, so
# `C.instance_eval { include M }` is C.include(M), an include, and a
# prepend a prepend, as in CRuby, while a def in the block defines a
# singleton method (--dump-load-record, record_ieval_main.rb.load-record).
# A `class << C` body's include stays an extend. The record only: the
# compiler refuses these calls inside an instance_eval block for now, so
# the program has no .expected.
module M
  def hi = "M#hi"
end

module P
  def name = "P(" + super + ")"
end

module N
  def ho = "N#ho"
end

class C
  def name = "C"
end

C.instance_eval do
  include M
  prepend P
  attr_accessor :x
end

C.instance_eval do
  def made = "C.made"
end

class << C
  include N
end

c = C.new
c.x = 1
p [c.hi, c.name, c.x, C.made, C.ho]
