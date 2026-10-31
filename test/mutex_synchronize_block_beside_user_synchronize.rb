# Mutex#synchronize handed its block as an argument (`&block`, a proc in a
# variable, a lambda) runs it under the lock and answers its value, in a
# program that defines a method named synchronize of its own.
# a top-level synchronize is Object's: it does not displace Mutex#synchronize
def synchronize = :top

module Locking
  def synchronize
    yield
  end
end

class Guarded
  include Locking
end

class Counter
  def initialize
    @n = 0
    @lock = Mutex.new
  end

  def synchronize(&block)
    @lock.synchronize(&block)
  end

  def bump = synchronize { @n += 1 }
  attr_reader :n
end

M = Mutex.new

def via_block(&block) = M.synchronize(&block)
def via_forward(&) = M.synchronize(&)
def twice(&block)
  a = M.synchronize(&block)
  b = M.synchronize(&block)
  [a, b]
end

p synchronize
p via_block { 42 }
p via_forward { :forwarded }
p twice { M.locked? }
pr = proc { M.owned? }
p M.synchronize(&pr)
la = -> { :lambda }
p M.synchronize(&la)
p M.synchronize { :literal }
p M&.synchronize { :safe_nav }
n = nil
p n&.synchronize { :never }
p M.locked?

# the user's own methods of that name still answer
p Guarded.new.synchronize { :user_module }
c = Counter.new
c.bump
c.bump
p c.n
p c.synchronize { :user_class }

# a Mutex out of an Array, and one beside the user's objects
locks = [Mutex.new, Guarded.new]
p locks[0].synchronize { :boxed_mutex }
p locks[1].synchronize { :boxed_guarded }
def via_poly(l, &block) = l.synchronize(&block)
p via_poly(locks[0]) { :poly_mutex }
p via_poly(locks[1]) { :poly_guarded }

# the lock is released when the block raises
begin
  via_block { raise "boom" }
rescue => e
  p e.message
end
p M.locked?
