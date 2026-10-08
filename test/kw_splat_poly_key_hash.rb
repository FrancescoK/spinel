# A `**` operand whose keys are of any class (`{ :a => 1, 1 => 2 }`, or a
# Symbol-keyed hash a later store widened) binds its Symbol keys to the
# keyword parameters, and a key that is no Symbol is an unknown keyword --
# a String "a" is not the keyword :a. The C compiler refused the direct
# call; a value of more than one class took the whole hash as one
# positional argument, or raised a TypeError at such a key when the hash
# came out of a ternary. A method without keywords still takes it as a
# Hash.
# spinel: gc-minor
def f(a: 0, b: 1) = [a, b]
def fr(a:) = a
def y(a: 0, b: 1) = yield(a, b)

class Box
  def initialize(a: 0, b: 1)
    @a = a
    @b = b
  end

  def pair = [@a, @b]
  def k(a: 0, b: 1) = [:box, a, b]
  def self.k(a: 0, b: 1) = [:box_c, a, b]
  def pos(x = 7) = [:box, x]
  def rest(*r) = [:box, r]
end

class Bag
  def k(a: 0, b: 1) = [:bag, a, b]
  def self.k(a: 0, b: 1) = [:bag_c, a, b]
  def pos(x = 7) = [:bag, x]
  def rest(*r) = [:bag, r]
end

KwStruct = Struct.new(:a, :b, keyword_init: true)
PlainStruct = Struct.new(:a, :b)
Point = Data.define(:a, :b)

def try
  p yield
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end

wide = { :a => 3, :b => 2 }
wide[3] = 4
wide.delete(3)
int_key = { :a => "s", 1 => 2 }
str_key = { :a => 1, "b" => 2 }
str_a = { :b => 1 }
str_a["a"] = 9
mixed = ARGV.empty? ? { :a => 5, "b" => 6 } : { :a => 5 }

# a direct call, an inlined yielding method, .new, a class method and send
try { f(**wide) }
try { f(**int_key) }
try { f(**str_a) }
try { fr(**str_a) }
try { f(**{ 1 => 2, :c => 3, :a => 4 }) }
try { y(**wide) { |a, b| [a, b] } }
try { y(**str_key) { |a, b| [a, b] } }
try { Box.new(**wide).pair }
try { Box.new(**int_key).pair }
try { Box.k(**wide) }
try { Box.k(**str_key) }
try { Box.new.send(:k, **int_key) }

# a Struct and a Data
try { KwStruct.new(**wide) }
try { KwStruct.new(**int_key) }
try { PlainStruct.new(**str_key) }
try { Point.new(**wide) }
try { Point.new(**str_a) }

# a hash of any key from a ternary
try { f(**mixed) }
try { y(**mixed) { |a, b| [a, b] } }
try { Box.new(**mixed).pair }
try { Point.new(**mixed) }

# a value of more than one class, and a class value
[Box.new, Bag.new].each do |o|
  try { o.k(**wide) }
  try { o.k(**int_key) }
  try { o.k(b: 0, **str_a) }
  try { o.k(**mixed) }
  try { o.pos(**str_key) }
  try { o.rest(**int_key) }
  try { o.send(:k, **wide) }
end
[Box, Bag].each do |cls|
  try { cls.k(**wide) }
  try { cls.k(**str_key) }
end

# a fresh operand each time, through the dispatch
def mk(i)
  h = { :a => i }
  h[i.to_s] = i if i.odd?
  h
end
bad = 0
sum = 0
100.times do |i|
  o = i.even? ? Box.new : Bag.new
  sum += o.k(**mk(i))[1]
rescue ArgumentError
  bad += 1
end
p [sum, bad]
