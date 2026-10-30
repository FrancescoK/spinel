# A call on a boxed Class value whose class method has two versions runs
# the version defined when the call runs.
class Animal
  def self.speak = "animal"
end
class Kitten < Animal
  def self.speak = "kitten1"
end
def all(ks) = ks.map { |k| k.speak }
ks = [Animal, Kitten]
p all(ks)
class Kitten
  def self.speak = "kitten2"
end
p all(ks)
