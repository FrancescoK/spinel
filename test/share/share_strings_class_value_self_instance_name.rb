# spinel: share
# A class method's `self.itself` answers the class object, though the class
# has an instance method of the same name: the instance method does not
# answer a class object, so the class is a value, and the call of a class
# method of another name on that value, among values of other classes, may
# be this class's.
class K
  def itself
    "inst"
  end

  def self.make
    self.itself
  end

  def self.keep(s)
    @kept = s
  end

  def self.get
    @kept
  end
end

class Other
  def keep(s)
    s.dup
  end

  def get
    +"zz"
  end
end

items = [K.make, Other.new]
s = +"abc"
items.each do |x|
  x.keep(s)
  t = x.get
  t << "!"
end
p s

# the instance method answers its own self.itself
class K
  def twice
    [self.itself, itself]
  end
end
p K.new.twice
