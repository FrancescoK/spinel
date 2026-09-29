# `callable.method(:call).arity` where the callable is only known at run
# time -- activesupport's Deprecation#arity_of_callable,
#   callable.respond_to?(:arity) ? callable.arity : callable.method(:call).arity
# over a proc or an object with #call -- reads the arity off the Method
# object the runtime built; the static form (a literal receiver of a known
# class) answered already.

class Handler
  def call(a, b) = a + b
end
class Wide
  def call(*args) = args.size
end
class Opt
  def call(a, b = 1, c = 2) = a + b + c
end

def arity_of_callable(callable)
  callable.respond_to?(:arity) ? callable.arity : callable.method(:call).arity
end

p arity_of_callable(->(a, b, c) { a })
p arity_of_callable(proc { |a| a })
p arity_of_callable(Handler.new)
p arity_of_callable(Wide.new)
p arity_of_callable(Opt.new)
p Handler.new.method(:call).arity
h = [Handler.new, Wide.new, Opt.new][1]
p h.method(:call).arity
