class Obj
  def name = "obj"
end

class Cb
  def initialize(&b) = @b = b
  def run(o) = o.instance_exec(&@b)
  def eval_on(o) = o.instance_eval(&@b)
end

class Bound
  def initialize(block) = @block = block
  def call(object, *) = object.instance_exec(*, &@block)
end

class Holder
  def show
    seen = nil
    pr = -> { seen = self }
    [Bound.new(pr), seen]
  end
end

o = Obj.new
plain = Object.new
p Cb.new { self.class }.run(o)
p Cb.new { self.class }.run(plain)
p Cb.new { |x| x.class }.eval_on(o)
p Cb.new { self.class }.eval_on(plain)

ctx = nil
b = Bound.new(->(a1) { ctx = [a1] })
b.call(plain, 1)
p ctx
b = Bound.new(->(a1, a2, a3) { ctx = [a1, a2, a3] })
b.call(o, 1, 2, 3)
p ctx
b = Bound.new(->(*args) { ctx = args })
b.call(plain, 4, 5)
p ctx

first = nil
second = nil
list = [-> { first = self }, -> { second = self }]
list.each { |pr| plain.instance_exec(&pr) }
p first.equal?(plain), second.equal?(plain)

h = Holder.new
bm, _ = h.show
bm.call(o)
p bm.call(o).equal?(o)

seen = nil
lam = -> { seen = self; 7 }
p Bound.new(lam).call(o)
p seen.equal?(o)
p lam.call
p seen.equal?(self)

begin
  Cb.new.run(o)
rescue LocalJumpError => e
  p [e.class, e.message]
end
begin
  Bound.new(->(a, b) { a }).call(o, 1)
rescue ArgumentError => e
  p [e.class, e.message]
end
