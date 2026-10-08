# Rebound self stays the runtime receiver when no method constrains its class.
# The top-level definitions keep the block's candidate-class set empty.
def receiver_name = "top level"
def receiver_value(x) = x + 1000

class UnconstrainedA
  def receiver_name = "receiver A"
  def receiver_value(x) = x + 1
end
class UnconstrainedB
  def receiver_name = "receiver B"
  def receiver_value(x) = x + 2
end

class UnconstrainedLexical
  def receiver_name = "lexical instance"
  def receiver_value(x) = x + 100
  def run(obj)
    p obj.instance_eval { receiver_name }
    p obj.instance_exec(10) { |x| receiver_value(x) }
    p obj.instance_eval { self.receiver_name }
  end
  def self.receiver_name = "lexical singleton"
  def self.receiver_value(x) = x + 200
  def self.run(obj)
    p obj.instance_eval { receiver_name }
    p obj.instance_exec(20) { |x| receiver_value(x) }
  end
end

UnconstrainedLexical.new.run(UnconstrainedA.new)
UnconstrainedLexical.new.run(UnconstrainedB.new)
UnconstrainedLexical.run(UnconstrainedA.new)
UnconstrainedLexical.run(UnconstrainedB.new)

# Class objects carry the same rebound marker without an instance-class arm.
class UnconstrainedClass
  def self.receiver_name = "runtime class"
  def self.receiver_value(x) = x + 3
end
UnconstrainedLexical.run(UnconstrainedClass)

# Top-level callers and missing runtime methods must not pick a lexical one.
def unconstrained_run(obj)
  p obj.instance_eval { receiver_name }
  p obj.instance_exec(30) { |x| receiver_value(x) }
end
unconstrained_run(UnconstrainedA.new)
unconstrained_run(UnconstrainedB.new)
unconstrained_run(Object.new)
