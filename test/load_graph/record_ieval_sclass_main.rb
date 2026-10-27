# The load record holds what an instance_eval or class_eval block inside a
# `class << C` body runs on C's singleton class: self there is the
# singleton class, so an include in either block is an extend of C, and
# an attr form's methods are C's class methods, and a def in the
# class_eval block defines a class method of C.
# The include was held as an include into C (--dump-load-record,
# record_ieval_sclass_main.rb.load-record). The record only: the compiler
# refuses these calls inside such a block for now, so the program has no
# .expected.
module M
  def hi = "M#hi"
end

module N
  def ho = "N#ho"
end

class C
end

class << C
  instance_eval do
    include M
    attr_accessor :x
  end
  class_eval do
    include N
    def made = "C.made"
  end
end

C.x = 1
p C.hi, C.ho, C.made, C.x
p C.singleton_class.include?(M), C.include?(M)
