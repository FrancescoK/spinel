# The shapes of #7444, each a value that may be nil on an object receiver.
# `make nil-check-test` compiles this with --nil-check and compares the
# report with shapes.nil-check: each shape is FACT-ONLY (the analysis's nil
# fact sees the nil the codegen helpers miss), the guarded reads agree, and
# nothing is HELPER-ONLY. Compiled for the report only: Spinel's answers
# here are the bugs #7444's later steps fix.
class Cell
  attr_reader :v
  def initialize(v) = @v = v
end

class Box
  attr_reader :v
  def initialize(v) = @v = v
  def hello = "hi"
end

class Talker
  def initialize(v) = @v = v
  def to_s = 42
end

class Item
  attr_reader :v
  def initialize(v) = @v = v
end

class Flag
  def initialize(on) = @on = on
  def on? = @on
end

class W
  def poke(x) = x
end

# a method whose value is a case with no else
def pick(n)
  case n
  when 1 then Box.new(1)
  end
end

# a method whose tail is a modifier-if return: nil when it is not taken
def find_flag(name)
  return Flag.new(true) if name == "-q"
  return Flag.new(false) if name == "-n"
end

def find_w(n)
  W.new if n > 3
end

def arg
  puts "arg evaluated"
  1
end

def run
  # a local whose only write is conditional
  b = Cell.new(1) if ARGV.size > 3
  p b.v
  # a case with no else, through a method
  p pick(2).hello
  # a by-value class, a case with no else
  p pick(2).v
  # NilClass#to_s answers, not Box's
  c = nil
  c = Talker.new(1) if ARGV.size > 3
  p c.to_s
  # the argument runs before the NoMethodError
  w = find_w(ARGV.size)
  p w.poke(arg)
  # an implicit nil out of a by-value class's method
  f = find_flag("-z")
  p f.on?
  # an Array element that is not there
  items = [Item.new(1)]
  e = items[ARGV.size + 5]
  p e.v
  # guarded: not nil
  g = pick(ARGV.size)
  p g.v if g
  return unless g
  p g.hello
end

run
