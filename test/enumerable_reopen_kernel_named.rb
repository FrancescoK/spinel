# A method a program adds to Enumerable is CRuby's for an Array, a Hash and a
# Range. A name that is also a private Kernel function still reaches the
# receiver's own method (`select` inside the body is Array#select, not
# Kernel#select), and a public Enumerable#open is called on an Array although
# Kernel has a private open.
module Enumerable
  def above_one = select { |x| x > 1 }
  def open = map { |x| x * 2 }
end

p [1, 2, 3].above_one
p (1..3).above_one
p({ 1 => :a, 2 => :b }.above_one.size)
p [1, 2, 3].open
p (1..3).open
