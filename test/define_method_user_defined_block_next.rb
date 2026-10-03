# A class with a define_method of its own: that method takes the block as a
# block and may call it, so a `next` in the block stays a `next`. Where the
# block becomes a method's body the `next` is retyped as a `return`
# (test/next_in_run_once_block.rb); done here, the `return` was the enclosing
# method's and `run` did not build.
class Reg
  def define_method(n, &b) = [n, b.call]

  def run
    v = define_method(:a) { next 1 if ARGV.length == 0; 2 }
    [v, :after]
  end

  def self.define_method(n, &b) = b.call

  def self.run
    v = define_method(:b) { next "s" if ARGV.length == 0; "t" }
    [v, :after]
  end
  X = define_method(:c) { next 3 if ARGV.length == 0; 4 }
end
r = Reg.new
p r.run, Reg.run, Reg::X
p r.define_method(:d) { next 5 if ARGV.length == 0; 6 }

# A class that is not Reg, above it or below it cannot reach Reg's
# define_method: there the block is the method's body, as in any program.
class Plain
  def base = 3
  define_method(:m) { |x| next 1 if x > 0; base }
  [:p, :q].each { |v| define_method("u_#{v}") { |x| next v if x > 0; :no } }
  define_method(:k) { |x, y: 1| next y if x > 0; base }
  class << self
    define_method(:cm) { |x| next "pos" if x > 0; "neg" }
  end
end
pl = Plain.new
p pl.m(5), pl.m(-1), pl.u_p(1), pl.u_q(-1), pl.k(1, y: 7), pl.k(-1), Plain.cm(1), Plain.cm(-1)

# Reg has no define_singleton_method of its own, so that one's block is a
# method's body for Reg too
Reg.define_singleton_method(:s) { |x| next 10 if x > 0; 20 }
pl.define_singleton_method(:t) { |x| next 10 if x > 0; base }
p Reg.s(1), Reg.s(-1), pl.t(1), pl.t(-1)

# a class below Reg reaches Reg's
class Sub < Reg
  Y = define_method(:e) { next 5 if ARGV.length == 0; 6 }
end
p Sub::Y
