# `def m(...) = instance_exec(...)`: instance_exec takes whatever its
# callers pass and hands it to the block, so callers that pass different
# numbers of arguments all forward (activerecord's Relation#_exec_scope:
# `instance_exec(...) || self`)
class Rel
  def initialize(n) = @n = n

  def run(...)
    instance_exec(...) || :none
  end
end

r = Rel.new(10)
p r.run { @n + 1 }
p r.run(2) { |a| @n * a }
p r.run(2, 3) { |a, b| @n + a + b }
p r.run { nil }
