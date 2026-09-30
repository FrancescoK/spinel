# defined?(recv.m) evaluates recv once per level and answers "method" when its value has a public m.
class Emp
  attr_reader :a
  attr_writer :w
  def initialize(a) = @a = a
  def work = 1
  def me; puts "me"; self; end
  def boom = raise("no")
  def self_work = defined?(self.work)
  def self_hid = defined?(self.hid)
  def bare_hid = defined?(hid)
  private
  def hid = 2
end
e = Emp.new(1)
p defined?(e.work), defined?(e.nope), defined?(e.a)
p defined?(e.hid), e.self_work, e.self_hid, e.bare_hid
p defined?(e.w = 1), defined?(e.a = 1), defined?(e&.work)
p defined?("s".upcase), defined?([1].nope), defined?([1][0]), defined?(!e)
x = nil
p defined?(x.foo), defined?(nil.to_s), defined?(x&.to_s)
p defined?(e.work.succ), defined?(e.work.nope), defined?(e.nope.succ)
p defined?(e.me.me.work)
p defined?(e.me.nope.work)
p defined?(e.boom.succ)
p defined?(e.work(zz)), defined?(e.work(1))
p defined?(Emp.new), defined?(Math.sqrt), defined?(Emp.nope), defined?(Nope.new)
p defined?(e.work { 1 })
y = rand < 2 ? 1 : "s"
p defined?(y.succ), defined?(y.upcase)

# Symbol#to_proc is lowered to a lambda before defined? sees it: still "method"
tp = :upcase
p defined?(:upcase.to_proc)
p defined?(tp.to_proc)
p defined?(lambda { 1 })
