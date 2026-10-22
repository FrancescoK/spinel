# `class << self; self; end` as an arm's value inside a block that can rebind
# self (define_method, instance_eval) still compiles and runs: the class is
# not known there, so the arm keeps the statement form.
class C
  define_method(:dm) { |k| x = if k then class << self; self; end end; 1 }
  def self.make
    o = Object.new
    o.instance_eval { y = if true then class << self; self; end end; 3 }
  end
end
p C.new.dm(true)
p C.make
