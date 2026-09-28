class Base
  def self.label = eval("1 + 1")
  def self.tag = "base"
end

class Child < Base
  def self.label = "child"
  def self.tag = "child<" + super + ">"
end

p Child.label
p Child.tag
