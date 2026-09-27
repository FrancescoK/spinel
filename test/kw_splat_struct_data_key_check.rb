# A `**h` into a Data or keyword Struct constructor is checked against the
# members as the literal form is: a Data member no key names is missing, a
# key naming no member is unknown. The hash is evaluated once.
Point = Data.define(:x, :y)
P3 = Data.define(:x, :y, :w)
Opts = Struct.new(:a, :b, keyword_init: true)
Plain = Struct.new(:a, :b)

$calls = 0
def none = {}
def extra = { y: 2, z: 3 }
def both = { y: 2 }
def counted
  $calls += 1
  { y: 5 }
end
def many = { x: 1, y: 2, w: 3, z: 4, q: 5 }
def partial = { x: 1 }
def unknown = { b: 2, c: 3 }
def unknowns = { c: 1, d: 2 }
def good = { b: 7 }

def try
  p yield
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end

try { Point.new(x: 1, **none) }
try { Point.new(x: 1, **extra) }
try { Point.new(x: 1, **both) }
try { Point.new(x: 1, **counted) }
p $calls
try { P3.new(**partial) }
try { P3.new(**many) }
try { Opts.new(a: 1, **unknown) }
try { Opts.new(a: 1, **unknowns) }
try { Opts.new(a: 1, **good) }
try { Plain.new(a: 1, **unknown) }
try { Plain.new(a: 1, **good) }
