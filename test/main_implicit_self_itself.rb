# A bare Object method at the top level, in a top-level def and in a class
# method sends to self (main, or the class), as CRuby does; it was a NameError.

p itself
p itself.class
p itself.equal?(self)
x = itself
p x.to_s
p to_s
p inspect
p dup.class
p tap { }.class
p is_a?(Object)
p nil?
p frozen?
p instance_of?(Object)
p [1, 2].map { itself }.size
3.times { |i| p itself.to_s if i == 2 }

def from_def
  itself
end
p from_def
def from_def_to_s = to_s
p from_def_to_s

class C
  def self.m
    itself
  end

  def self.n
    [1].map { itself }
  end
end
p C.m
p C.n

module M
  def self.m = itself
end
p M.m

# a method of the program's own named itself still answers
class D
  def self.itself = :d
  def self.m = itself
end
p D.m


# so does one from a module the top level includes
module Mine
  def clone = :mine
end
include Mine
p clone
