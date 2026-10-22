# A module included by a later `Cat.include` gives Cat a method its
# superclass also has. The call ahead of it reaches Animal#speak in CRuby
# ("..."); Spinel's one chain, the last, would answer "kind"; refused.
module Kind
  def speak = "kind"
end
class Animal
  def speak = "..."
end
class Cat < Animal
end
c = Cat.new
puts c.speak
Cat.include(Kind)
puts c.speak
