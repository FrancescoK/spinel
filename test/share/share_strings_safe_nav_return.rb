# spinel: share
# spinel: gc-minor
# spinel: gc-stress
# A fresh block result needs no return handle; a demanded result keeps &.'s guard.
def fresh_tail(s) = s&.then { |x| x + "!" }
def renamed(s) = s.yield_self { |v| v + "!" }
def shared_local(s)
  t = s&.then { |x| x + "!" }
  u = t
  u << "?" if u
  t
end
p fresh_tail(nil), fresh_tail("ab"), renamed("ab")
p shared_local(nil), shared_local(+"ab")

def identity_tail(s) = s&.then { |x| x }
def tapped_tail(s) = s&.tap { |x| x << "!" }
def yielded_tail(s) = s&.yield_self { |x| x }
p identity_tail(nil), tapped_tail(nil), yielded_tail(nil)
s = +"identity"
t = identity_tail(s)
p t.equal?(s)
t << "!"
p s
u = tapped_tail(s)
p u.equal?(s), s
v = yielded_tail(s)
p v.equal?(s)
s << "?"
p t, u, v

# A fresh block result must not pick up its receiver's earlier publication.
s = +"source"
t = identity_tail(s)
t << "!"
t = renamed(s)
p t.equal?(s)
t << "?"
p s, t

# A conversion whose identity is not observed keeps ordinary safe navigation.
def nullable_text(s) = s&.to_s
p nullable_text(nil), nullable_text(+"plain")
