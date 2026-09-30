# A class method whose block instance_exec runs on another object is emitted
# as an instance method of that object's class for the length of the block.
# When the method has the name of an instance method of that class, the move
# made it read as that method: the scope index, rebuilt during a move, filed
# the moved class method under the class's key, so a poly dispatch of the name
# inside a later block called a class method for a Plain and raised
# ArgumentError, and a scan of the scopes took Plain's own method for shadowed
# and dropped its arm (NoMethodError).
class Plain
  def label = "Plain#label"
end

class Other
  def label = "Other#label"
end

class Runner
  # the block inlined into instance_exec
  def self.label(o, xs)
    o.instance_exec { xs.map { |x| x.label } }
  end
end

class Evaluator
  # instance_eval, the same move
  def self.label(o, xs)
    o.instance_eval { xs.map { |x| x.label } }
  end
end

class Handed
  # a proc handed to instance_exec that reads self
  def self.label(o, xs)
    pr = proc { [self.class.to_s] + xs.map { |x| x.label } }
    o.instance_exec(&pr)
  end
end

xs = [Plain.new, Other.new]
p Runner.label(Plain.new, xs)
p Evaluator.label(Plain.new, xs)
p Handed.label(Plain.new, xs)
p xs.reverse.map(&:label)
