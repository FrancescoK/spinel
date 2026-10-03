# A program with a define_method of its own: that method takes the block as
# a block and may call it, so a `next` in the block stays a `next`. Where the
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
