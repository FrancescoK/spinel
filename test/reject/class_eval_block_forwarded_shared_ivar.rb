# Inside class_eval, @x is the class's own; in the block given to `run`, which
# runs it with instance_exec, it is the object's. Which `run` a call reaches
# (Box's, or some other class's of that name that yields) depends on the
# receiver, known only at run time; refused rather than answered from a guess.
class Box
  def initialize; @x = :box; end
  def run(&b) = instance_exec(&b)
end
class A
  def self.x = @x
end
box = Box.new
p A.class_eval { @x = :a; [@x, box.run { @x }] }
