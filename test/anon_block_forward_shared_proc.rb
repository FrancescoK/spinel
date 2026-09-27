# An anonymous `&` forwarded into a call that the shared-proc dispatch handles
# (a receiver method with a keyword argument, reached from a method that also
# forwards the same `&` elsewhere) is a live proc, not a block literal to
# lower. Four of the dispatch arms already said so; this one did not, and the
# call was refused as "proc literal without a block".
class A
  def inner(state: nil, &b) = b.call(state)
end

def render(r, &)
  if A === r
    r.inner(state: 1, &)
  else
    render(A.new, &)
  end
end

p render(A.new) { |s| "got #{s}" }
p render(1)     { |s| "got #{s}" }

# the same forwarding spelled with a named block parameter
def render2(r, &blk)
  if A === r then r.inner(state: 2, &blk) else render2(A.new, &blk) end
end
p render2(A.new) { |s| "got #{s}" }
p render2(1)     { |s| "got #{s}" }
