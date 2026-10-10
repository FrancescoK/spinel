# A default whose begin raises and retries from its rescue reads the
# earlier parameter's new value at each attempt (#8320): the call site's
# temp for that parameter is written under the rescue's setjmp.
def f(n = 0, v = begin
  n += 1
  raise "x" if n < 2
  n
rescue
  retry
end)
  v
end
p f
p f(5)

class Tries
  def go(n = 0, v = begin
    n += 1
    raise ArgumentError, "again" if n < 3
    n * 10
  rescue ArgumentError
    retry
  end)
    [n, v]
  end
end
p Tries.new.go
p Tries.new.go(1)

def g(n = 0, v = (n += 1; Integer("x#{n}") rescue n))
  [n, v]
end
p g

# a default writing an earlier parameter the body reads runs in the callee
class Bump
  def go(n = 0, v = (n += 1; n)) = [n, v]
end
p Bump.new.go
p Bump.new.go(4)
