class Box
  def size = 3
end

def pick(x, o)
  x == 0 ? 5 : (x == 1 ? o.zork : raise(ArgumentError, "bad #{x}"))
end

def label(x, o)
  if x == 0
    "zero"
  else
    (x == 1 ? o.zork : raise(ArgumentError, "label #{x}"))
  end
end

def ratio(x, o)
  return 1.5 if x == 0
  unless x == 1
    raise ArgumentError, "ratio #{x}"
  else
    o.zork
  end
end

def nested(x, o)
  x.zero? ? o.size : ((unless x == 1 then raise(ArgumentError, "nested #{x}") else o.zork end))
end

def attempt
  yield
rescue NoMethodError => e
  "NoMethodError #{e.name}"
rescue ArgumentError => e
  "ArgumentError #{e.message}"
end

o = Box.new
p pick(0, o)
p attempt { pick(1, o) }
p attempt { pick(2, o) }
p label(0, o)
p attempt { label(1, o) }
p attempt { label(2, o) }
p ratio(0, o)
p attempt { ratio(1, o) }
p attempt { ratio(2, o) }
p nested(0, o)
p attempt { nested(1, o) }
p attempt { nested(2, o) }
