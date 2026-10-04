# A superclass written as `Class.new(Base)` inherits Base's methods; the
# anonymous class in between defines nothing. `Class.new` alone is Object.
class Base
  def hi = "base"
  def self.make = new
end

class FromAnon < Class.new(Base)
  def hi = super + "!"
end

class Plain < Class.new
  def hi = "plain"
end

p FromAnon.new.hi
p FromAnon.make.hi
p FromAnon.ancestors.include?(Base)
p FromAnon.new.is_a?(Base)
p Plain.new.hi
p Plain.ancestors.include?(Base)
