# A `super` into Hash with no block of its own passes the block the method
# was given, as CRuby's does; called without a block, Hash's iterator
# answers its Enumerator.
class Opts < Hash
  def each
    puts "x"
    super
  end

  def select(&b)
    super
  end
end
o = Opts[a: 1, b: 2]
o.each { |k, v| p [k, v] }
p o.each.class
p o.select { |k, v| v > 1 }
