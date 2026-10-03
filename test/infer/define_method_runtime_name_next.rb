# A define_method whose name is only known at run time registers no method,
# so a `next` in its block is left as it is. Retyped as a `return`, as it is
# where the block becomes a method's body (test/next_in_run_once_block.rb),
# it was read as the enclosing method's: `make` answered a boxed value where
# it answers a Symbol, and `count` one where it answers an Integer.
class Maker
  def self.make(n)
    define_method(n) { next 1 if ARGV.length == 0; 2 }
    :made
  end

  def self.count(names)
    names.each { |n| define_method(n) { next "s" if ARGV.length == 0; 2 } }
    names.size
  end
end
p Maker.make(:x), Maker.count([:y, :z])
