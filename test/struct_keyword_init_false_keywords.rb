# A keyword_init: false Struct takes keywords as one positional Hash, its
# first member, as CRuby does: a key naming a member binds nothing and a key
# naming none is no error. The literal keys and `**` operands merge in source
# order, a later key winning; an operand that brings nothing passes no Hash,
# and one that is not a Hash raises TypeError where it stands.
S3 = Struct.new(:x, :y, keyword_init: false)
S1 = Struct.new(:x, keyword_init: false)

def lit(v) = (puts "lit #{v}"; v)
def none = {}
def some = { b: 2 }
def strs = { "s" => 1 }
def a2 = { a: 2 }

def try
  p yield
rescue ArgumentError, TypeError => e
  puts "#{e.class}: #{e.message}"
end

try { S3.new(x: 1) }
try { S3.new(x: 1, y: 2) }
try { S3.new(z: 1) }
try { S1.new(x: 1) }
try { S3.new(**{ x: 1 }) }
try { S3.new(z: 1, **{ b: 2 }) }
try { S3.new(z: lit(1), **some, w: lit(3)) }
try { S3.new(a: 1, **a2) }
try { S3.new(**a2, a: 1) }
try { S3.new(**some, **{ c: 3 }) }
try { S3.new(**none) }
try { S3.new(**{}) }
try { S3.new(**nil) }
try { S3.new("q" => 1) }
# a key of another class stays in the Hash as it is
try { S3.new(**strs) }
try { S3.new(z: 1, **strs) }
try { S3.new(**strs, z: 1) }
try { S3.new("q" => lit(1), **some) }
try { S3.new(z: lit(1), **1) }
try { S3.new(1, y: 2) }
try { S3.new(1, 2, a: 3) }
s = S3.new(x: 1)
p s.x[:x] + 1
p s.y
t = S3.new(k: "v", **some)
p t.x.keys

# a bare `new` in the Struct's own class method takes them the same way
class Opts < Struct.new(:x, :y, keyword_init: false)
  def self.plain = new(x: 1)
  def self.merged(h) = new(z: 1, **h)
  def self.spread(h) = new(**h)
end
try { Opts.plain }
try { Opts.merged(some) }
try { Opts.spread(some) }
try { Opts.spread(none) }
