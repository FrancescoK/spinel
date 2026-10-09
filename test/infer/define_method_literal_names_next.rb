# A `next` in a define_method block inside a method body is a `return` of
# the defined method (test/next_in_run_once_block.rb), not of the enclosing
# method: `make` answers a Symbol where the `next 1` would have made it a
# boxed value, and `count` an Integer where `next "s"` would have. `mixed`
# defines its methods from a literal list with interpolated names.
class Maker
  def self.make
    define_method(:x) { next 1 if ARGV.length == 0; 2 }
    :made
  end

  def self.count
    [:y, :z].each { |n| define_method(n) { next "s" if ARGV.length == 0; "t" } }
    2
  end

  def self.mixed
    [:a, :b].each { |v| define_method("m_#{v}") { next 1 if ARGV.length == 0; 2 } }
    :mixed
  end
end
p Maker.make, Maker.count, Maker.mixed
p Maker.new.x, Maker.new.y, Maker.new.z, Maker.new.m_a, Maker.new.m_b
