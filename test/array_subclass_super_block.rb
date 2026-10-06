# A `super` into Array with no block of its own passes the block the method
# was given, as CRuby's does: from a method that names it (`&blk`), takes it
# anonymously (`&`), yields, or never mentions it, into initialize and into
# Array's iterators. Called without a block, the iterator answers its
# Enumerator; `super(&nil)` passes none.
class Page < Array
  def each
    puts "x"
    super
  end
end
Page[1, 2].each { |e| p e }
p Page[1].each.class

class Named < Array
  def each(&blk)
    puts "n"
    super
  end
end
Named[3].each { |e| p e }
p Named[3].each.class

class Anon < Array
  def each(&)
    puts "a"
    super
  end
end
Anon[4].each { |e| p e }

class Yielder < Array
  def each
    yield 0 if block_given?
    super
  end

  def map
    super
  end

  def select
    r = super
    r.size
  end
end
Yielder[5, 6].each { |e| p e }
p Yielder[5, 6].map { |e| e * 10 }, Yielder[5].map.class
p Yielder[1, 2, 3].select(&:odd?), Yielder[1, 2, 3].select { |e| e > 1 }

class Sized < Array
  def initialize(n, &b) = super
end
p Sized.new(2), Sized.new(3) { |i| i * i }

class Grid < Array
  def initialize(n)
    super
  end
end
p Grid.new(2), Grid.new(3) { |i| i * 3 }

class Forward < Array
  def each(&b)
    puts "f"
    super(&b)
  end
end
Forward[7].each { |e| p e }

class NoBlock < Array
  def each
    super(&nil)
  end
end
p NoBlock[8].each { |e| p e }.class
