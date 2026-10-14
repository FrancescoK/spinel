class Pt
  attr_reader :x

  def initialize = @x = 1
end

pr = proc { |o| o.dup }
q = pr.call(Pt.new)
p q.x
p q.equal?(pr.call(q))
cl = lambda { |o| o.clone }
p cl.call(q).x
