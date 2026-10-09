# spinel: share
# spinel: gc-minor
# Nested Array patterns bind their elements, not an Array guessed from <<.

s = +"ab"
case [[s]]; in [[t]]; end
t << "c"
p s

s = +"ab"
case [[s]]; in [[t]]; end
s << "c"
p t

def pattern_forward
  s = +"ab"
  case [[s]]; in [[t]]; end
  t << "c"
  p s
end
pattern_forward

def pattern_reverse
  s = +"ab"
  case [[s]]; in [[t]]; end
  s << "c"
  p t
end
pattern_reverse

1.times do
  s = +"ab"
  case [[s]]; in [[t]]; end
  t << "c"
  p s
end

1.times do
  s = +"ab"
  case [[s]]; in [[t]]; end
  s << "c"
  p t
end

def nested_neighbor_0
  s = +"ab"
  case [[[s]]]; in [[[t]]]; end
  t << "c"
  p s
end
nested_neighbor_0

def nested_neighbor_1
  s = +"ab"
  case [{k: [s]}]; in [{k: [t]}]; end
  t << "c"
  p s
end
nested_neighbor_1

def nested_neighbor_2
  s = +"ab"
  case [[s]]; in [[t]] if t.length > 0; end
  t << "c"
  p s
end
nested_neighbor_2

def nested_neighbor_3
  s = +"ab"
  case [[s]]; in [[String => t]]; end
  t << "c"
  p s
end
nested_neighbor_3

def nested_neighbor_4
  s = +"ab"
  case [[s]]; in [[t] => a]; end
  t << "c"
  p s
end
nested_neighbor_4

def nested_neighbor_5
  s = +"ab"
  case [1, [s]]; in [*, [t]]; end
  t << "c"
  p s

end
nested_neighbor_5
