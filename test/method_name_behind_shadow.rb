# __method__ and __callee__ name the method as written. A method a prepend
# or an extend moves behind another of its name runs under a shadow name
# (`__prep_0_go`, `__inc 0 hi`), and the two answered that shadow.
module P
  def go = [:p, __method__, super]
end

class K
  prepend P
  def go = [:k, __method__, __callee__]
end

module E
  def hi = [:e, __method__]
end

class Q
  extend E
  def self.hi = [:q, __method__, super]
end

p K.new.go
p Q.hi
