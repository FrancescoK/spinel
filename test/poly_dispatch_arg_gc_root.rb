# A call on a boxed receiver evaluates its arguments into temps, left to
# right, and its arm passes them on only after the arguments to their right
# have run and it has built its keyword hash. A temp is the only holder of
# a value its argument allocated (`tags.uniq`, a boxed Time), and of a
# variable's value once an argument to its right, or a default the arm
# fills in, writes the variable; and the result temp of a no-else `if`
# with no effect of its own is set ahead of the receiver. None of these
# was rooted, so a collection in between freed the value and the callee
# read whatever had taken its slot (a SIGSEGV in sp_str_length, a Time of
# year 8920956).
#
# `churn` collects and then allocates, so a freed slot is handed out again.
# The receiver `source` and the last arguments run it once the values
# before them are held only by their temps.

def churn
  GC.start
  junk = []
  64.times { |k| junk << ["j#{k}", "k#{k}", "l#{k}"]; junk << Time.at(k) }
  junk.size
end

def mark(s)
  churn
  s
end

def fresh_tags(i)
  ["a#{i}", "b#{i}", "a#{i}"]
end

class Bag
  def merge(other) = other
end

# a Hash or a Bag, so `.merge` dispatches on a boxed receiver
def source(i)
  churn
  return Bag.new if i < 0
  { title: "t#{i}" }
end

3.times do |i|
  st = i >= 0 ? "published" : "draft"
  h = source(i).merge(at: (Time.at(1_700_000_000 + i) if st == "published"),
                      note: ("n#{i}" if i >= 0),
                      tags: fresh_tags(i).uniq,
                      slug: mark("s#{i}"))
  GC.start
  puts h[:title], h[:at].to_i, h[:note], h[:tags].join(","), h[:slug]
end

# positionals, through a user method on a boxed receiver
class Pair
  def put(a, b) = [a, b]
end

class Twin
  def put(a, b) = [b, a]
end

def pick(i) = i > 5 ? Twin.new : Pair.new

2.times do |i|
  r = pick(i).put(fresh_tags(i).uniq, [mark("p#{i}")])
  GC.start
  p r
  # the variable's value, once the argument after it has written it
  s = "v#{i}"
  r = pick(i).put(s, (s = nil; mark("w#{i}")))
  GC.start
  p r
end

# a variable's value, once a default the arm fills in has written it
class Keeper
  def initialize(i) = (@x = "k#{i}")
  def drop! = (@x = nil; churn; 7)
  def give(o) = o.take(@x)
end

class Taker < Keeper
  def take(a, b = drop!) = [a, b]
end

class Swapper < Keeper
  def take(a, b = drop!) = [b, a]
end

2.times do |i|
  k = i > 5 ? Swapper.new(i) : Taker.new(i)
  r = k.give(k)
  GC.start
  p r
end

# the same through a class method, when the receiver can be a Class
class Lender
  def self.drop! = ($lent = nil; churn; 8)
  def self.lend(a, b = drop!) = [a, b]
  def lend(a, b = 0) = [b, a]
end

def lender(i) = i > 5 ? Lender.new : Lender

2.times do |i|
  $lent = "g#{i}"
  r = lender(i).lend($lent)
  GC.start
  p r
end

# a `**` operand the dispatch merges runs code that writes the global the
# argument before it was read from: a #to_hash conversion, or the #hash of a
# key of a Hash of any keys
class Converter
  def to_hash = ($lent = nil; churn; { z: 1 })
end

class HashKey
  attr_reader :v
  def initialize(v) = (@v = v)
  def hash = ($lent = nil; churn; @v)
  def eql?(o) = o.is_a?(HashKey) && o.v == @v
end

class Collector
  def gather(a, **kw) = [a, kw.size]
end

class Reverser
  def gather(a, **kw) = [kw.size, a]
end

def collector(i) = i > 5 ? Reverser.new : Collector.new

2.times do |i|
  $lent = "h#{i}"
  opts = [Converter.new, { y: 2 }][0]
  r = collector(i)
  p r.gather($lent, **opts)
  keyed = { HashKey.new(i) => 1 }
  $lent = "q#{i}"
  p r.gather($lent, **keyed)
end

# a String Range argument carries its two Strings by value
class Spanner
  def ends(r, x) = [r.begin, r.end, x]
end

class Flipper
  def ends(r, x) = [x, r.end, r.begin]
end

def spanner(i) = i > 5 ? Flipper.new : Spanner.new

2.times do |i|
  p spanner(i).ends(("a#{i}".."z#{i}"), [mark("e#{i}")])
end

# code that runs with no call in sight: an interpolation's #to_s in a later
# argument, a keyword value or a default the arm fills in, and a key's
# #hash as the keyword hash is built or a `**` forwarded
class Dropper
  def to_s = ($lent = nil; churn; "d")
end

class Putter
  def put(a, b) = [a, b]
  def named(a: nil, b: nil) = [a, b]
  def fill(a, b = "#{$dropper}") = [a, b]
end

class Turner
  def put(a, b) = [b, a]
  def named(a: nil, b: nil) = [b, a]
  def fill(a, b = "#{$dropper}") = [b, a]
end

def putter(i) = i > 5 ? Turner.new : Putter.new
$dropper = Dropper.new

def forward(r, i, **) = ($lent = "x#{i}"; r.gather($lent, **))

2.times do |i|
  r = putter(i)
  d = Dropper.new
  $lent = "m#{i}"
  p r.put($lent, "#{d}")
  $lent = "o#{i}"
  p r.named(a: $lent, b: "#{d}")
  $lent = "f#{i}"
  p r.fill($lent)
  g = collector(i)
  key = HashKey.new(i)
  $lent = "u#{i}"
  p g.gather($lent, key => 1)
  keyed = { HashKey.new(i) => 1 }
  p forward(g, i, **keyed)
end

# a keyword value can be a value object, which carries its String field by
# value
class Tag
  def initialize(i) = (@s = "v#{i}")
  def to_s = @s
end

2.times do |i|
  h = source(i).merge(tag: Tag.new(i), slug: mark("s#{i}"))
  GC.start
  puts h[:tag].to_s
end
