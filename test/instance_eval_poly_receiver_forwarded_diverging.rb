class Cb
  def initialize(k) = @k = k
end
class M
  def event(n) = n
  def around(&b) = Cb.new(:around)
end
def find(flag, &)
  m = flag ? M.new : :none
  m.instance_eval(&) if block_given?
  m
end
def run(flag, &)
  m = flag ? M.new : :none
  v = m.instance_eval(&)
  [v.class, m.class]
end
p find(true) {
  event :start
  around { |a| a }
}.class
p find(true) { event 1; "s" }.class
p run(true) { event :start; around { |a| a } }
p run(true) { event 1; "s" }
