# instance_exec(*args, &block) forwarding the method's own block, whose
# value its call sites' blocks give in different types, used as a value
# (activerecord's Relation#_exec_scope: `instance_exec(...) || self`)
class Rel
  def initialize(n) = @n = n

  def run(*args, &block)
    x = instance_exec(*args, &block)
    x
  end

  def run_or_self(*args, &block)
    instance_exec(*args, &block) || :self
  end
end

r = Rel.new(10)
p r.run { @n + 1 }
p r.run(2) { |a| "n=#{@n * a}" }
p r.run(2, 3) { |a, b| [@n, a, b] }
p r.run_or_self { nil }
p r.run_or_self(4) { |a| @n + a }
p r.run_or_self(:x) { |s| s.to_s }
