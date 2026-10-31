# A constant holding Mutex's class (`Mutex.new.class`) can be reopened like
# the class itself, and Mutex#synchronize still runs its block there. A
# `then` the program adds to StandardError, which is Kernel's name and no
# Mutex's, is still the exception's own when handed a block.
K = Mutex.new.class
p K
class K
  def self.hi = :hi
end
p K.hi
m = Mutex.new
p m.synchronize { 1 }
b = proc { :forwarded }
p m.synchronize(&b)

class StandardError
  def then = :se_then
end
blk = proc { |x| :block }
p ArgumentError.new("x").then(&blk)
