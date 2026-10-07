# Flag-only. User methods named catch and throw keep their ordinary value
# routes; they are not builtin non-local jumps.
def catch(tag)
  yield
end

def throw(tag, value)
  value
end

s = +"ab"
t = catch(:tag) { s }
t << "c"
p s

s = +"ab"
t = catch(:tag) { throw(:tag, s) }
t << "d"
p s
