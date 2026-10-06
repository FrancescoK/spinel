# Array#concat with several arrays whose elements are of another class than
# the receiver's. The inference took only a one-argument concat as evidence
# of what the receiver holds, so with two or more the receiver stayed a typed
# Array and the generated C pushed an Integer into a String array (or a
# String into an Integer one), which did not build. Every argument is
# evidence now, as push's are; one that is no Array raises TypeError before
# anything is stored.

def t(k)
  r = [+"a"]
  r.concat([1], [:s])
  p r
  q = [1]
  q.concat([2], ["x"], [])
  p q
  w = [1.5]
  w.concat([[2], 1][k], [3])
  p w
  s = [+"b"]
  begin
    s.concat([1], 7)
  rescue TypeError => e
    p e.message
  end
  p s
end

t(ARGV.size)
