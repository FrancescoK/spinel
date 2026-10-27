# A method defined ahead of a later include is called by a statement that
# runs after both its def and the class's first body, so the call in its
# body runs before the include. It reaches Animal#speak in CRuby ("...");
# Spinel's one chain, the last, would answer "kind"; refused.
module Kind
  def speak = "kind"
end
class Animal
  def speak = "..."
end
class Cat < Animal
end
def talk(c) = c.speak
puts talk(Cat.new)
class Cat
  include Kind
end
puts talk(Cat.new)
