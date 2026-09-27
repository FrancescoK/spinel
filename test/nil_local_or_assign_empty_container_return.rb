# A method returning a local that starts nil and is then given an empty
# container returns the container, not nil.

def hash_or(k, v)
  h = nil
  h ||= {}
  h[k] = v
  h
end
p hash_or(:a, 1)

def hash_if_nil
  h = nil
  h = {} if h.nil?
  h
end
p hash_if_nil

def hash_reassign
  h = nil
  h = {}
  h
end
p hash_reassign

def hash_new_or
  h = nil
  h ||= Hash.new
  h
end
p hash_new_or

def hash_explicit_return
  h = nil
  h ||= {}
  h[:a] = 1
  return h
end
p hash_explicit_return

def array_or(v)
  a = nil
  a ||= []
  a << v
  a
end
p array_or(1)

def caller_of_hash
  hash_or(:z, 9)
end
p caller_of_hash

x = hash_or("s", "t")
x["u"] = "w"
p x

y = array_or(1)
y << 2
p y

def maybe_hash(flag)
  h = nil
  h ||= {} if flag
  h
end
p maybe_hash(true)
p maybe_hash(false)

def string_or
  s = nil
  s ||= +""
  s << "x"
  s
end
p string_or
