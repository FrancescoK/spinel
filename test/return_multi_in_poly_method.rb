# `return a, b` builds an Array; in a method that also answers other kinds
# of value (a String, another Array literal) the method's value is boxed, and
# the Array goes out boxed too.
def pick(o)
  case o
  when Integer then return -o, o
  when String then "str:#{o}"
  else [0, 0]
  end
end

def early(flag)
  return 1, 2 if flag
  "none"
end

p pick(4), pick("a"), pick(nil), early(true), early(false)
