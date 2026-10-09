# spinel: share
# spinel: gc-minor
# A splatted Hash default is the argument itself and retains its identity.

s = +"ab"
h = Hash.new(*[s]); t = h[:k]
t << "c"
p s

s = +"ab"
h = Hash.new(*[s]); t = h[:k]
s << "c"
p t

def hash_forward
  s = +"ab"
  h = Hash.new(*[s]); t = h[:k]
  t << "c"
  p s
end
hash_forward

def hash_reverse
  s = +"ab"
  h = Hash.new(*[s]); t = h[:k]
  s << "c"
  p t
end
hash_reverse

1.times do
  s = +"ab"
  h = Hash.new(*[s]); t = h[:k]
  t << "c"
  p s
end

1.times do
  s = +"ab"
  h = Hash.new(*[s]); t = h[:k]
  s << "c"
  p t
end

def default_from_local
  s = +"ab"
  args = [s]
  h = Hash.new(*args)
  h[:missing] << "c"
  p s
end
def default_once
  n = 0
  h = Hash.new(*[(n += 1; +"ab")])
  h[:a] << "c"
  p h[:b]
  p n
end
def default_frozen
  h = Hash.new(*["ab"])
  begin
    h[:a] << "c"
  rescue FrozenError
    puts "frozen"
  end
end
default_from_local
default_once
default_frozen
p Hash.new(*[])[:k]
p Hash.new(*[nil])[:k]
p Hash.new(*[7])[:k]

# Forwarded and mutated argument arrays use their run-time length.
def hash_runtime_forward(*args) = Hash.new(*args)
s = +"ab"
h = hash_runtime_forward(s)
h[0] << "c"
p s
s = +"ab"
args = [s, s]
args.pop
h = Hash.new(*args)
s << "c"
p h[0]
