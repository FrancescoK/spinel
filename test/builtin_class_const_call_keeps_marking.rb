# The cases where a call named like a core class's method still reaches a
# program class method, so the reachability pass keeps marking it by name (the
# partner of builtin_class_const_call_skips_class_method): a core class the
# program reopens with a class method of the name (Array.zeros, whose body is
# the program's), and a class value of no known class (`ks[1].new(2)`,
# `k.new(3)`), which may be Cell and so keeps Cell.new and what it calls. The
# constant call Array.new(2, 7) next to them still runs Array's own.
class Array
  def self.zeros(n)
    log_zeros(n)
    Array.new(n, 0)
  end

  def self.log_zeros(n)
    puts "zeros #{n}"
  end
end

class Cell
  def self.new(n)
    seed(n)
  end

  def self.seed(n)
    [n, n]
  end

  def self.zeros(n)
    seed(0)
  end
end

ks = [Array, Cell]
puts ks[0].new(2).inspect
puts ks[1].new(2).inspect
k = ARGV.empty? ? Cell : Array
puts k.new(3).inspect
puts Array.new(2, 7).inspect
puts Array.zeros(2).inspect
puts Cell.zeros(2).inspect
