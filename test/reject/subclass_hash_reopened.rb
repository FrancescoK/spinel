# A Hash subclass in a program that also reopens Hash: resolve_parents
# would take the program's own class named Hash for the superclass.
class Hash
  def twice = merge(self)
end
class Registry < Hash
end
r = Registry.new
r[:a] = 1
p r.twice
