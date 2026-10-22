# A block's value in parentheses ending in a yield is the yield's value: in
# a method whose callers' blocks answer values of different kinds, the
# Array a map builds from it, or a push collects it into, holds each kind.
def each_twice
  n = 0
  [1, 2].map { |x| (n += x; yield x) }
end
p each_twice { |x| x * 10 }
p each_twice { |x| "s#{x}" }

def wrap
  r = (1..2).map { |x| (x; yield(x)) }
  r
end
p wrap { |v| v + 1 }
p wrap { |v| [v] }

def collect
  out = []
  [5, 6].each { |x| out << (x; yield(x)) }
  out
end
p collect { |v| v - 1 }
p collect { |v| v.to_s }

# a Float block's value is kept a Float, not narrowed to the Integer slot
# another caller's block types
def m8
  out = []
  [1, 2].each { |x| out << (x += 1; yield(x)) }
  out
end
p m8 { |x| x * 10 }
p m8 { |x| x.to_f }
p m8 { |x| nil }
