# A method that hands its block on with `&block` to a yielding method answers
# what the block returns. When the program's blocks for it return different
# types, the value is boxed, and it must keep the class of an application
# object the block returns so a call on it dispatches.

class R; def ok? = "R"; end
class S; def ok? = "S"; end
class Never; def ok? = "never"; end   # no block returns one

def run_block = yield(0)
def with(&block) = run_block(&block)
def outer(&block) = with(&block)

p with { |c| c + 1 }
puts with { |c| R.new }.ok?

# two levels of forwarding
p outer { |c| "str" }
puts outer { |c| R.new }.ok?

# a block that returns one of two application classes
[0, 1].each { |i| puts with { |c| i == 0 ? R.new : S.new }.ok? }

# a module method forwarding to an instance's yield inside begin/ensure
class Pool
  def with
    begin
      yield 1
    ensure
      nil
    end
  end
end
module Db
  @pool = Pool.new
  def self.with(&block) = @pool.with(&block)
end
class Result; def ok? = true; end
def result_of = Db.with { |c| Result.new }
p result_of.ok?
p Db.with { |c| 1 }
p Db.with { |c| [c] }
puts "yes" if Db.with { |c| true }
puts "no" unless Db.with { |c| c > 1 }
puts Never.name

# a block forwarded to a receiverless method of the same class
class Wrapper
  def run = yield
  def forward(&block) = run(&block)
end
w = Wrapper.new
p w.forward { 1 }
p w.forward { R.new }.ok?
