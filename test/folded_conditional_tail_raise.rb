# A method ends in a parenthesised conditional whose condition is answered
# at compile time: the conditional is its live arm alone, and that arm raises.
class Box
  def initialize(n) = @n = n
  def n = @n
end

def pick(x)
  return 5 if x == 0
  (x.respond_to?(:zork) ? x.zork : raise(ArgumentError))
end

def ratio(x)
  return 1.5 if x == 0
  (if x.is_a?(String) then x.zork else raise(ArgumentError, "ratio #{x}") end)
end

def label(x)
  return "zero" if x == 0
  (unless x.is_a?(Integer) then x.zork else fail(ArgumentError, "label #{x}") end)
end

def mark(x)
  return :none if x == 0
  (block_given? ? x.zork : raise(ArgumentError, "mark #{x}"))
end

def list(x)
  return [1] if x == 0
  (x.is_a?(Integer) ? raise(IndexError, "list #{x}") : x.zork)
end

def flag(x)
  return true if x == 0
  x > 5 ? false : (x.respond_to?(:zork) ? x.zork : raise(ArgumentError, "flag #{x}"))
end

def box(x)
  return Box.new(7) if x == 0
  (x.respond_to?(:zork) ? x.zork : raise(ArgumentError, "box #{x}"))
end

def attempt
  yield
rescue ArgumentError, IndexError => e
  "#{e.class} #{e.message}"
end

p pick(0)
p attempt { pick(1) }
p ratio(0)
p attempt { ratio(1) }
p label(0)
p attempt { label(1) }
p mark(0)
p((mark(1) rescue "rescued"))
p list(0)
p attempt { list(1) }
p flag(0)
p flag(9)
p attempt { flag(1) }
p box(0).n
p attempt { box(1) }
