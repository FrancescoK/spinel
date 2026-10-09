# A populated method candidate memo is queried again during a scope move.
class Plain
  def label = "plain"
end
class Other
  def label = "other"
end
class Runner
  def label(o, xs)
    o.instance_exec { xs.map { |x| x.label } }
  end
end
xs = [Plain.new, Other.new]
p xs.map { |x| x.label }
p Runner.new.label(Plain.new, xs)
p xs.reverse.map { |x| x.label }
