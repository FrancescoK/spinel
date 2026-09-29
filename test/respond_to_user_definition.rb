# A class's own respond_to? answers for its objects, and a program defining
# one still has respond_to? on everything else (it was folded from the class
# chain, and the builtin surface was dropped).
class Shy
  def respond_to?(name, all = false) = name == :yes
  def hi = 1
end
class Plain
  def hi = 2
end
s = Shy.new
p s.respond_to?(:hi), s.respond_to?(:yes), Plain.new.respond_to?(:hi)
p 5.respond_to?(:abs), "x".respond_to?(:nope), [1].respond_to?(:each)
w = [5, s][ARGV.size]
p w.respond_to?(:abs)
