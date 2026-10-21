# Rebound self uses the user output method's return value.
class PlanWriter
  def puts(*args) = :mine
  def go(&block) = instance_eval(&block)
end
p PlanWriter.new.go { puts "hi" }
class PlanReopenedWriter
  def go(&block) = instance_eval(&block)
end
class PlanReopenedWriter
  def puts(*args) = :reopened
end
p PlanReopenedWriter.new.go { puts "hi" }
