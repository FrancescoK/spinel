# Flag-only. Route refusals the default build keeps (#6179) leave the
# route to the share rule under the flag: where the rule shares the String,
# the route hands on the handle. An element read of a literal holding a
# variable's String answers that String, so the name it is written to
# names it too. A String mutator whose receiver is `to_s` (or another call
# answering its receiver) takes the variable's handle before an argument
# that rebinds the variable runs. A global Array the variable is pushed
# into holds its handle. Each case runs in a method of its own.
def literal_array
  s = +"xy"
  t = [s][0]
  t.prepend("q")
  p s
end
literal_array

def literal_hash
  s = +"xy"
  t = { a: s }[:a]
  t << "!"
  p s
end
literal_hash

def literal_last
  s = +"ab"
  t = [1, s].last
  t << "c"
  p s, t
end
literal_last

def literal_second
  s = +"m"
  u = +"n"
  t = [s, u][1]
  t << "!"
  p s, u
end
literal_second

def to_s_rebind
  e = +"a"
  q = e
  q << "!"
  r = e.to_s << (e = +"b")
  p r, q, e
end
to_s_rebind

def to_s_chain
  e = +"a"
  q = e
  q << "1"
  r = e.to_s.to_s << (e = +"b")
  p r, q, e
end
to_s_chain

def to_s_concat
  e = +"a"
  q = e
  q << "1"
  r = e.to_s.concat(e = +"b")
  p r, q, e
end
to_s_concat

def global_push
  s = +"a"
  $ga = []
  $ga << s
  $ga[0] << "!"
  p s
end
global_push

def global_push_call
  s = +"g"
  $gb = []
  $gb.push(s)
  $gb.first << "?"
  p s, $gb
end
global_push_call
