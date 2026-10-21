# A class method called through a `class << self` alias on a subclass
# reads the subclass's class-level instance variables, as a call by the
# method's own name does: on a constant, on a local or a parameter holding
# the class, from `self.class` in an instance method, and through an alias
# a subclass makes of the inherited method.

class Shape
  class << self
    attr_accessor :table

    def lookup(key)
      table[key]
    end
    alias fetch_entry lookup
    alias_method :entry, :lookup

    def via_self(key)
      fetch_entry(key)
    end
  end
  self.table = { a: 0 }

  def describe(key)
    self.class.fetch_entry(key)
  end
end

class Square < Shape
  self.table = { a: 1 }
  class << self
    alias square_entry lookup
  end
end

class Cube < Square
  self.table = { a: 2 }
end

def from_local
  k = Square
  k.fetch_entry(:a)
end

def from_param(k)
  [k.fetch_entry(:a), k.entry(:a), k.lookup(:a)]
end

def from_choice(flag)
  k = flag ? Cube : Square
  k.square_entry(:a)
end

p Shape.fetch_entry(:a)
p Square.entry(:a)
p Cube.via_self(:a)
p from_local
p from_param(Shape)
p from_param(Square)
p from_param(Cube)
p from_choice(true)
p from_choice(false)
p Cube.square_entry(:a)
p Square.new.describe(:a)
p Cube.new.describe(:a)
p [Square, Cube].map { |k| k.send(:fetch_entry, :a) }

# Only subclasses are held as values here: the base class's own method is
# copied into each of them, and no value reaches the base's.
class Plain
  class << self
    attr_accessor :table

    def lookup(key)
      table[key]
    end
    alias fetch_entry lookup
  end
end

class Tinted < Plain
  self.table = { a: 3 }
end

class Shaded < Plain
  self.table = { a: 4 }
end

def from_tinted
  k = Tinted
  k.fetch_entry(:a)
end

def pick(k)
  [k.lookup(:a), k.fetch_entry(:a)]
end

p from_tinted
p pick(Tinted)
p pick(Shaded)

# A send with a literal name on a parameter holding the class runs that
# method on the class held, by the method's own name or by an alias. These
# classes are reached by no other call of the method on a value.
class Ledger
  class << self
    attr_accessor :rows

    def row(key)
      rows[key]
    end
    alias row_at row
  end
end

class Daily < Ledger
  self.rows = { a: 5 }
end

class Weekly < Ledger
  self.rows = { a: 6 }
end

def by_send(k)
  [k.send(:row_at, :a), k.public_send(:row, :a), k.__send__(:row_at, :a)]
end

p by_send(Daily)
p by_send(Weekly)
