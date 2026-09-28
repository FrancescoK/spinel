# A local holding a class is only folded to that class when every write to
# it assigns it: a multiple-assignment, for, pattern or &&= write can rebind it.
class M1
  def initialize(x) = (@x = x)
  def to_s = "M1 #{@x}"
  def self.tag = "t1"
end

class M3
  def initialize(x) = (@x = x)
  def to_s = "M3 #{@x}"
  def self.tag = "t3"
end

def multi(n)
  m = M1
  m, _ = M3, 1 if n == 2
  m.new(n)
end

def splat(n)
  m = M1
  *_, m = 1, M3 if n == 2
  m.new(n)
end

def and_write(n)
  m = M1
  m &&= M3 if n == 2
  m.new(n)
end

def for_var(n)
  m = M1
  for m in [M3] do end if n == 2
  m.new(n)
end

def pattern(n, k)
  m = M1
  case k
  in m if n == 2
  else
  end
  m.new(n)
end

def in_block(n)
  m = M1
  [1].each { m, _ = M3, 1 } if n == 2
  m.new(n)
end

def name_of(n)
  m = M1
  m, _ = M3, 1 if n == 2
  m.name
end

def class_method(n)
  m = M1
  m, _ = M3, 1 if n == 2
  m.tag
end

def builtin_name(n)
  m = String
  m, _ = Integer, 1 if n == 2
  m.name
end

def or_write_same(n)
  m = M1
  m ||= M1
  m.new(n)
end

puts multi(1), multi(2)
puts splat(1), splat(2)
puts and_write(1), and_write(2)
puts for_var(1), for_var(2)
puts pattern(1, M3), pattern(2, M3)
puts in_block(1), in_block(2)
puts name_of(1), name_of(2)
puts class_method(1), class_method(2)
puts builtin_name(1), builtin_name(2)
puts or_write_same(1)
