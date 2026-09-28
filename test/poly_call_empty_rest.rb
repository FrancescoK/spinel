# A user `call(*args)` reached through the boxed-callable dispatch with no
# arguments gets an empty Array for its splat, never nil.
class Fn
  def call(*args, &blk) = invoke(args, blk)
  def invoke(args, blk) = "n=#{args.size} #{args.inspect}"
end
def pick(i) = [Fn.new, proc { |*a| "proc#{a.size}" }, 5][i]
f = pick(0)
p f.call
p f.call(1, 2)
q = pick(1)
p q.call
