# A replaced version of a class's method is a C function of its own,
# spelled from the method's name and its number (`f#redef1`, which mangles
# to f_redef1). A method the program names f_redef1 itself spells the same
# C name. The clash was settled by renaming the method `f`, which does not
# move the version's spelling, so the two stayed one symbol and the
# program failed to build. The version's own spelling is renamed now.

class K
  def f_redef1 = :own
  def f = 1
  X = new.f
  def f = 2
end
p K::X, K.new.f, K.new.f_redef1

# on the class side
class J
  def self.g_redef1 = :own
  def self.g = 1
  X = g
  def self.g = 2
end
p J::X, J.g, J.g_redef1
