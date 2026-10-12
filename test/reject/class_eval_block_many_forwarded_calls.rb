# As class_eval_block_forwarded_shared_ivar.rb, after 64 other calls to the
# same `run` in the block: every one of them is still checked.
class Box
  def initialize; @x = :box; end
  def run(&b) = instance_exec(&b)
end
class Other
  def run = yield
end
class A
  def self.x = @x
end
box = Box.new
o = Other.new
pr = proc { 1 }
p A.class_eval {
  @x = :a
  r = [
    box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr),
    box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr),
    box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr),
    box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr),
    box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr),
    box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr),
    box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr),
    box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr), box.run(&pr)
  ]
  [@x, r.size, o.run { @x }]
}
