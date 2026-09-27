# The keywords of a Data or keyword Struct constructor with a `**h` are
# evaluated in source order, each once, as CRuby does: a literal before the
# splat runs before the hash, one after it runs after, and all of them run
# before the constructor checks its keys. A String range literal held in a
# temporary while the hash is built stays rooted: the hash builder collects
# the object heap and allocates past the string heap's trigger.
Point = Data.define(:x, :y)
Late = Data.define(:x, :y)
Both = Data.define(:x, :y, :w)
Name = Data.define(:first, :last)
Opts = Struct.new(:a, :b, keyword_init: true)
LateOpts = Struct.new(:a, :b, keyword_init: true)
Plain = Struct.new(:a, :b)
Span = Data.define(:range, :tag)

$calls = 0
def lit(v) = (puts "lit #{v}"; v)
def str(s) = (puts "str #{s}"; s)
def hash(h) = (puts "hash"; h)
def counted
  $calls += 1
  puts "counted"
  { y: 5 }
end

def try
  p yield
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end

try { Point.new(x: lit(1), **hash({ y: 2 })) }
try { Late.new(**hash({ x: 3 }), y: lit(4)) }
try { Both.new(x: lit(1), **hash({ y: 2 }), w: lit(3)) }
try { Both.new(w: lit(3), x: lit(1), **hash({ y: 2 })) }
try { Name.new(first: str("Ada"), **hash({ last: "Lovelace" })) }
try { Point.new(x: lit(1), **counted) }
p $calls
try { Point.new(x: lit(1), **hash({})) }
try { Both.new(x: lit(1), **hash({ z: 2 }), w: lit(3)) }
try { Opts.new(a: lit(1), **hash({ b: 2 })) }
try { LateOpts.new(**hash({ a: 1 }), b: lit(2)) }
try { Plain.new(a: lit(1), **hash({ b: 2 })) }

def collected(n)
  GC.start
  ("pad" * 400_000).size
  { tag: "t#{n}" }
end
3.times do |n|
  s = Span.new(range: ("a#{n}".."z#{n}"), **collected(n))
  p [s.range.first, s.range.last, s.tag]
end
