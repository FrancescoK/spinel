# A class's own singleton method named raise, exit or each is no builtin
# either: a receiverless call in a class method finds it first, so the nil
# narrowing does not take it for one that does not come back or that throws
# its block's value away.

class Lenient
  def self.raise(msg) = nil

  def self.check(x)
    raise "nil" if x.nil?
    puts(x > 0)
  rescue NoMethodError
    puts "NoMethodError"
  end
end
Lenient.check(2)
Lenient.check(nil)

class Quiet
  class << self
    def exit(*a) = nil
  end

  def self.leave(x)
    exit unless x
    puts(x.is_a?(Integer))
    puts(x < 9)
  rescue NoMethodError
    puts "NoMethodError"
  end
end
Quiet.leave(2)
Quiet.leave(nil)

module Soft
  def abort(msg) = nil
end

class Extended
  extend Soft

  def self.check(x)
    abort "nil" if x.nil?
    puts(x >= 1)
  rescue NoMethodError
    puts "NoMethodError"
  end
end
Extended.check(5)
Extended.check(nil)

# A class-level each that keeps its block's value hands the array out.
class Keeper
  def self.each = (@got = yield)
  def self.got = @got
end

class Rows
  def initialize = (@rows = [3, 1, 2])
  def leak = Keeper.each { @rows }

  def count
    i = 0
    while i < @rows.size
      puts(@rows[i] > 0)
      i += 1
    end
  rescue NoMethodError
    puts "NoMethodError"
  end
end
r = Rows.new
r.leak
Keeper.got[4] = 9
r.count
