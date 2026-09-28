o = Object.new
p o.instance_exec(5, k: 2) { |a, k: 1| [a, k] }
p o.instance_exec(5) { |a, k: 1| [a, k] }
def mm(a, k: 1) = [a, k]
p method(:mm).to_proc.call(5, k: 2)
class Cal; def call(a, h = nil) = [:cal, a, h]; end
pr = proc { |a, k: 1| [a, k] }
boxed = [pr, Cal.new]
p boxed[0].call(5, k: 2)
