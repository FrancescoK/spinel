# A call through self.class of a yielding class method feeds its block to
# that method's yield, as a call on the class's constant does: through a
# super into the parent's yielding class method with a block of its own,
# in a method's tail and as a statement.
class B
  def self.check
    puts "B #{yield}"
    nil
  end

  def self.twice
    yield + yield
  end
end

class D < B
  def self.check
    super { yield * 2 }
  end

  def self.twice
    super { yield + 1 }
  end

  def go = self.class.check { 21 }

  def stmt
    self.class.check { 5 }
    nil
  end

  def sum = self.class.twice { 10 }
end

p D.new.go
D.new.stmt
p D.new.sum
p D.check { 1 }
