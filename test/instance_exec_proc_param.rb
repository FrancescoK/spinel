# instance_exec(args, &pr) where pr is a positional or keyword parameter:
# the proc literals the call sites pass run with self = the receiver. The
# call raised NoMethodError at run time.
class Ctx
  def greet(name) = "hi #{name}"
end

class World
  def on(_source, guard: nil, &block)
    context = Ctx.new
    r = guard ? context.instance_exec("ada", &guard) : "no guard"
    puts r
    context.instance_exec("ada", &block) if block
  end
end

def fleet(_name, &block)
  World.new.instance_eval(&block) if block
end

fleet "demo" do
  on :tick, guard: ->(n) { "g #{n} #{greet(n)}" } do |e|
    puts greet(e)
  end
  on :tock do |e|
    puts greet(e + "!")
  end
end

def run(g) = Ctx.new.instance_exec("bob", &g)
p run(->(n) { greet(n) })
p run(proc { |n| n * 2 })
