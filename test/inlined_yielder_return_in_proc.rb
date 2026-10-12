# A `return` in a yielding method that is spliced into its caller leaves
# only that method, whatever body the call sits in. Inside a proc, lambda,
# Thread or Fiber body it took the body's own return instead: the top-level
# proc ended the script, and the Thread raised LocalJumpError.
module M
  def self.t(sec)
    return yield(sec) if sec.nil?
    yield(sec) + 1
  end

  def self.e(x)
    begin
      return yield(x) if x > 0
      -1
    ensure
      puts "ensure #{x}"
    end
  end

  def self.r(x)
    begin
      raise "boom" if x > 5
      return yield(x) if x > 0
      0
    rescue => err
      return err.message.size
    end
  end

  def self.s(x)
    return if x
    yield 7
  end

  def self.outer(x)
    return t(x) { |v| v.inspect.size } if x.nil?
    t(x) { |v| v * 2 }
  end

  def self.pw
    pr = proc { yield }
    pr.call
    :pw
  end

  def self.v(x)
    pw { return yield(x) }
    :v_end
  end
end

pr = proc { p M.t(nil) { |s| s.inspect.size }; p M.t(4) { |s| s * 10 } }
pr.call
l = lambda { p M.t(nil) { |s| s.inspect.size }; 9 }
p l.call
Thread.new { p M.t(nil) { |s| s.inspect.size } }.join
Thread.new { p M.e(2) { |v| v + 100 }; p M.e(0) { |v| v } }.join
f = Fiber.new { p M.r(3) { |v| v * 3 }; p M.r(9) { |v| v }; p M.r(0) { |v| v } }
f.resume
proc { M.s(true) { |v| p v }; M.s(false) { |v| p v }; puts "after s" }.call
proc { p M.outer(nil); p M.outer(3) }.call
p M.v(3) { |a| a + 1 }
proc { p M.v(4) { |a| a + 1 } }.call

# The guard's dead branch must still compile inside a generator or Thread
# body: the spliced method has a block there too.
class Bag
  def initialize; @d = [1, 2]; end

  def each
    return @d.dup.each unless block_given?
    @d.each { |x| yield x }
    self
  end
end
bag = Bag.new
p Enumerator.new { |y| bag.each { |x| y << x * 10 } }.to_a
Thread.new { p bag.each { |x| x }.class }.join

# The block's own `return` still leaves the method the proc was made in.
def home
  pr = proc { M.t(nil) { |s| return [:from_block, s] }; :not_here }
  pr.call
  :fell_through
end
p home

# And the proc's own `return` after the call still leaves that method.
def home2
  pr = proc { x = M.t(nil) { |s| 5 }; return [:proc_ret, x] }
  pr.call
  :fell_through
end
p home2

def home3
  [1, 2].map { |i| proc { M.t(i == 1 ? nil : i) { |s| s.inspect.size } }.call }
end
p home3

# A top-level proc's own `return` still ends the script.
pr2 = proc { a = M.t(nil) { |s| 1 }; p a; return; p :never }
pr2.call
p :never
