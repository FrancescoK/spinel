# An include through a Class held in a variable (a loop over class
# constants) is refused: the ancestor chain is baked at compile time, so the
# class must be named by a constant. It compiled to a NoMethodError at run
# time before.
module Unfriendly
  def unfriendly? = true
end
[Array, NilClass].each do |klass|
  klass.send(:include, Unfriendly)
end
p [].unfriendly?, nil.unfriendly?
