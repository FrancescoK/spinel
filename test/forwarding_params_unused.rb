# A `...` the method body hands nowhere takes any arguments, as CRuby's
# does: positional, a splat, keywords, a block. console's Output::Null is
# `def call(...) = nil`, and a log call reaches it through the boxed
# output's dispatch with a splat (`@output.call(subject, *arguments, ...)`),
# which was refused; a direct `n.call(*a)` built C that did not compile.
class Null
  def call(...) = nil
  def first(a, ...) = a
  def each(...) = block_given? ? yield(1) : :none
  def size(...) = 0
end
n = Null.new
a = [1, 2]
p n.call, n.call(1, 2, k: 3) { }, n.call(*a, **{x: 1})
p n.first(:a), n.first(:b, 2, 3, k: 1), n.first(*a)
p n.each, n.each { |x| x + 1 }
p n.size(*a)
outs = [n, Object.new]
p outs.first.call(*a, severity: :warn)

class Terminal
  def call(subject = nil, *arguments, severity: :info, **options, &block) = "T #{subject} #{arguments} #{severity}"
end
class Filter
  def initialize(output) = @output = output
  def call(subject, *arguments, **options, &block)
    @output.call(subject, *arguments, severity: :warn, **options, &block)
  end
end
p Filter.new(Terminal.new).call("s", 1)
p Filter.new(Null.new).call("s", 2)
