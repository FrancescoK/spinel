# An alias ahead of a redefinition in the same class keeps the earlier
# body (#3737), which runs under the alias's name: its super and
# __method__ still ask for the name its def has, as CRuby's do. super
# raised NoMethodError for the alias's name, and __method__ answered it.
class Base
  def add(x) = "Base#add #{x}"
end
class Parent < Base
  def add(x) = "P #{x} / #{super} / #{__method__}"
  alias push add
  def add(x) = "P2 #{x}"
end
p Parent.new.push(1), Parent.new.add(1)
