# The nil narrowing takes raise, exit and abort for Kernel's, which do not
# come back, and each, tap, times and the like for the builtin iterators,
# which throw their block's value away. A method the program defines by one
# of those names may do neither, so a nil read after it is still a nil.

# A raise that comes back: the rest of the list is reachable with x nil.
class Lenient
  def raise(msg) = nil
  def exit = nil

  def check(x)
    raise "nil" if x.nil?
    p x
    puts(x > 0)
  rescue NoMethodError
    puts "NoMethodError"
  end

  def leave(x)
    exit unless x
    puts(x.is_a?(Integer))
    puts(x < 9)
  rescue NoMethodError
    puts "NoMethodError"
  end
end
Lenient.new.check(2)
Lenient.new.check(nil)
Lenient.new.leave(2)
Lenient.new.leave(nil)

# An each that keeps its block's value: the block hands out the array, and
# a gap written through it reaches the index loop.
class Keeper
  attr_reader :got

  def each = (@got = yield)
  def tap = (@got = yield)
end

class Rows
  def initialize = (@rows = [3, 1, 2])

  def leak(k) = k.each { @rows }

  def count
    i = 0
    while i < @rows.size
      v = @rows[i]
      puts(v > 0)
      i += 1
    end
  rescue NoMethodError
    puts "NoMethodError"
  end
end
r = Rows.new
k = Keeper.new
r.leak(k)
k.got[4] = 9
r.count

def tapped
  a = [1.5, 2.5]
  k = Keeper.new
  k.tap { a }
  k.got << nil
  i = 0
  while i < a.size
    p a[i]
    puts(a[i] < 9)
    i += 1
  end
rescue NoMethodError
  puts "NoMethodError"
end
tapped
