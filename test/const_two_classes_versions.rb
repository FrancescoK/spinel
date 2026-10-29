# A constant a run-time condition binds to one of two classes, or defines
# under a condition: a call on it reaches the version of the method that
# the class it names has when the call runs, before and after a later
# redefinition.
class A
  def self.hi = "A1"
end
class B
  def self.hi = "B1"
end
class Other
  def self.hi = "Other1"
end
S = [1, 2].sum == 3 ? A : B
p S.hi
class A
  def self.hi = "A2"
end
class B
  def self.hi = "B2"
end
class Other
  def self.hi = "Other2"
end
p S.hi

unless $nope
  class Late
    def self.hi = "L1"
  end
end
p Late.hi
class Late
  def self.hi = "L2"
end
p Late.hi

# the other shapes a conditional value has: case, ||, begin, and a leaf that
# is no constant (the call then reaches whatever the constant may name)
class C1
  def self.hi = "C1a"
end
class C2
  def self.hi = "C2a"
end
T = case [1, 2].sum when 4 then C1 when 3 then C2 else Other end
U = C1 || C2
V = begin; [1].empty? ? C1 : C2; end
def pick = [C2, C1].first
W = pick
p T.hi, U.hi, V.hi, W.hi
class C1
  def self.hi = "C1b"
end
class C2
  def self.hi = "C2b"
end
p T.hi, U.hi, V.hi, W.hi
