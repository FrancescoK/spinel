# Guards keep the binding types of the underlying pattern. Mutate and read
# the bound String without depending on aliases to its source.

def array_if
  s = +"ab"
  case [s]
  in [t] if t.size == 2
  end
  t.replace("zz")
  p t
  t << "z"
  p t
  t.upcase!
  p t
  t[0] = "a"
  p t
  t.insert(1, "b")
  p t
  t.clear
  p t
end
array_if

def array_unless
  s = +"ab"
  case [s]
  in [t] unless t.empty?
  end
  t.replace("zz")
  p t
  t << "z"
  p t
  t.upcase!
  p t
  t[0] = "a"
  p t
  t.insert(1, "b")
  p t
  t.clear
  p t
end
array_unless

def hash_if
  s = +"ab"
  case {k: s}
  in {k: t} if t.size == 2
  end
  t.replace("zz")
  p t
  t << "z"
  p t
  t.upcase!
  p t
  t[0] = "a"
  p t
  t.insert(1, "b")
  p t
  t.clear
  p t
end
hash_if

def hash_unless
  s = +"ab"
  case {k: s}
  in {k: t} unless t.empty?
  end
  t.replace("zz")
  p t
  t << "z"
  p t
  t.upcase!
  p t
  t[0] = "a"
  p t
  t.insert(1, "b")
  p t
  t.clear
  p t
end
hash_unless

def find_if
  s = +"ab"
  case [s]
  in [*, t, *] if t.size == 2
  end
  t.replace("zz")
  p t
  t << "z"
  p t
  t.upcase!
  p t
  t[0] = "a"
  p t
  t.insert(1, "b")
  p t
  t.clear
  p t
end
find_if

def find_unless
  s = +"ab"
  case [s]
  in [*, t, *] unless t.empty?
  end
  t.replace("zz")
  p t
  t << "z"
  p t
  t.upcase!
  p t
  t[0] = "a"
  p t
  t.insert(1, "b")
  p t
  t.clear
  p t
end
find_unless

def capture_if
  s = +"ab"
  case [s]
  in [t] => whole if whole.size == 1
  end
  t.replace("zz")
  p t
  t << "z"
  p t
  t.upcase!
  p t
  t[0] = "a"
  p t
  t.insert(1, "b")
  p t
  t.clear
  p t
end
capture_if

def capture_unless
  s = +"ab"
  case s
  in String => t unless t.empty?
  end
  t.replace("zz")
  p t
  t << "z"
  p t
  t.upcase!
  p t
  t[0] = "a"
  p t
  t.insert(1, "b")
  p t
  t.clear
  p t
end
capture_unless

def nested_array_if
  s = +"ab"
  case [{item: s}]
  in [{item: t}] if t.size == 2
  end
  t.replace("zz")
  p t
  t << "z"
  p t
  t.upcase!
  p t
  t[0] = "a"
  p t
  t.insert(1, "b")
  p t
  t.clear
  p t
end
nested_array_if

def nested_hash_unless
  s = +"ab"
  case {items: [s]}
  in {items: [t]} unless t.empty?
  end
  t.replace("zz")
  p t
  t << "z"
  p t
  t.upcase!
  p t
  t[0] = "a"
  p t
  t.insert(1, "b")
  p t
  t.clear
  p t
end
nested_hash_unless

def nested_find_if
  s = +"ab"
  case {items: [s]}
  in {items: [*, t, *]} if t.size == 2
  end
  t.replace("zz")
  p t
  t << "z"
  p t
  t.upcase!
  p t
  t[0] = "a"
  p t
  t.insert(1, "b")
  p t
  t.clear
  p t
end
nested_find_if

def nested_capture_if
  s = +"ab"
  case {item: s}
  in {item: String => t} if t.size == 2
  end
  t.replace("zz")
  p t
  t << "z"
  p t
  t.upcase!
  p t
  t[0] = "a"
  p t
  t.insert(1, "b")
  p t
  t.clear
  p t
end
nested_capture_if

# A rightward pattern in a guarded arm keeps the same element type.
s = +"ab"
case [s]
in [rightward_source] if rightward_source.size == 2
  [rightward_source] => [rightward_target]
  rightward_target << "z"
  p rightward_target
end

# A rejected guard still binds its local; it does not run the arm's mutation.
s = +"ab"
case [s]
in [rejected_if] if rejected_if.empty?
  rejected_if << "z"
else
  p rejected_if
end
p s

s = +"cd"
case [s]
in [rejected_unless] unless rejected_unless.size == 2
  rejected_unless.insert(1, "z")
else
  p rejected_unless
end
p s

# Bare bindings use the same unwrapped path, for both guard kinds.
case +"ab"
in bare_if if bare_if.size == 2
  bare_if[0] = "z"
  p bare_if
end
case +"ab"
in bare_unless unless bare_unless.empty?
  bare_unless << "z"
  p bare_unless
end
