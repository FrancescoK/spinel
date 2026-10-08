# A `**true` or `**false` operand is a TypeError naming the value, raised
# before any keyword binds, and a `**nil` carries no keywords, so a required
# keyword it leaves unbound is missing -- through a method, its **rest, a
# positional parameter, an inlined yielding method, an object receiver and
# self, a receiver of several classes, a class method, `send`, `initialize`
# and a Data or Struct constructor. So does an operand of another class
# into a positional parameter, unless it is a slot that is nil at run time.
# The operand runs once, where it stands.
# spinel: gc-minor
class Base
  def initialize(a: 0, b:) = (@a = a; @b = b)
  def v = [@a, @b]
  def kr(a:) = [:base, a]
  def k(a: 0) = [:base, a]
  def self_nil = kr(**nil)
  def self_true = k(**true)
  def self.ck(a:) = a
end

class Sub < Base
  def kr(a:) = [:sub, a]
  def k(a: 0) = [:sub, a]
end

class Other
  def kr(a:) = [:other, a]
  def k(a: 0) = [:other, a]
  def g(a, b = nil) = [:other, a, b]
  def pr(*r, z) = [:other, r, z]
end

class Pos
  def initialize(a, b = nil) = (@v = [a, b])
  attr_reader :v
  def g(a, b = nil) = [:pos, a, b]
  def pr(*r, z) = [:pos, r, z]
end

Point = Data.define(:x, :y)
Opts = Struct.new(:a, :b, keyword_init: true)
Plain = Struct.new(:a, :b)

def k(a: 0) = a
def kr(a:) = a
def kr2(a:, b:, c: 3) = [a, b, c]
def rest(**kw) = kw
def both(a: 0, **kw) = [a, kw]
def req_rest(a:, **kw) = [a, kw]
def pos(*r) = r
def opt(a, b = nil) = [a, b]
def one(a) = a
def two(a, b) = [a, b]
def pr(*r, z) = [r, z]
def pr2(a, *r, z) = [a, r, z]
def yo(a, b = nil) = yield(a, b)
def yk(a:) = yield(a)
def tru = true
def nf = nil
def gt(x) = x > 1

$log = []
def side(v) = ($log << v; v)
def yes = ($log << :yes; true)
def none = ($log << :none; nil)
def at(x, a:) = [x, a]

def try
  p yield
rescue ArgumentError, TypeError => e
  puts "#{e.class}: #{e.message}"
end

# true and false: a literal, a method's answer, a local
b = gt(0)
try { k(**true) }
try { k(**false) }
try { k(**tru) }
try { k(**gt(2)) }
try { k(**b) }
try { kr(a: 1, **true) }
try { rest(**true) }
try { k(**1r) }
try { rest(**2i) }
try { both(a: 1, **false) }
try { rest(**nil, **tru) }
try { pos(1, **true) }
try { opt(1, **true) }
try { opt(1, x: 1, **false) }
try { one(**tru) }

# nil: required keywords are missing, optional ones take their defaults
try { kr(**nil) }
try { kr(**nf) }
try { kr2(**nil) }
try { kr2(**nil, a: 1) }
try { kr2(**nil, b: 1, a: 2) }
try { kr2(a: 1, **nil) }
try { kr2(**nil, **nil) }
try { req_rest(**nil) }
try { req_rest(**nil, a: 1, z: 2) }
try { k(**nil) }
try { rest(**nil) }
try { both(**nil) }
h = { a: 1, z: 2 }
try { rest(**nil, **h) }
try { rest(**nf, **h) }
try { req_rest(**nil, **h) }

# the operand runs once, where it stands
try { k(**side(true)) }
try { kr(**side(nil)) }
try { kr(**side(false), a: 1) }
try { at(side(1), **yes) }
try { at(side(2), **none) }
try { kr(**none, a: 3) }
p $log

# an inlined yielding method, an object receiver, self, a class method, send
try { yk(**nil) { |v| v } }
try { yk(**true) { |v| v } }
try { [1, 2].map { |i| yk(**nil) { |v| v + i } } }
o = Base.new(b: 1)
s = Sub.new(b: 1)
try { o.kr(**nil) }
try { s.kr(**nil, a: 1) }
try { s.k(**true) }
try { o.k(**false) }
try { s.self_nil }
try { o.self_true }
try { Base.ck(**nil) }
try { Base.ck(**false) }
try { send(:kr, **nil) }
try { send(:k, **true) }
try { send(:opt, 1, **false) }

# a receiver of several classes
[Base.new(b: 1), Other.new].each do |r|
  try { r.k(**true) }
  try { r.k(**false, a: 1) }
  try { r.k(**nf) }
  try { r.kr(**nil) }
  try { r.kr(**nf, a: 2) }
end
try { [Sub.new(b: 1), Other.new].map { |r| r.kr(**nil, a: 3) } }
try { [Other.new, Other.new, Base.new(b: 1)].map { |r| r.k(**b) } }

# positional and post-rest parameters: true and false raise, nil is no
# argument at all
try { opt(1, **nf) }
try { two(1, **nf) }
try { two(1, **false) }
try { pr(1, **true) }
try { pr(1, **nil) }
try { pr(1, 2, **nf) }
try { pr2(1, 2, **false) }
try { pr2(side(1), side(2), **none) }
try { yo(1, **nf) { |x, y| [x, y] } }
try { yo(1, **true) { |x, y| [x, y] } }
try { Pos.new(1, **nf).v }
try { Pos.new(1, **true).v }
try { Plain.new(1, **nf) }
try { Plain.new(1, **true) }
try { send(:pr, 1, **nf) }
[Pos.new(0), Other.new].each do |r|
  try { r.g(1, **true) }
  try { r.g(1, **nil) }
  try { r.g(1, **nf) }
  try { r.pr(1, **false) }
  try { r.pr(1, 2, **nf) }
end
p $log

# another class into positional parameters: a TypeError, but a slot that
# is nil at run time is no argument
class Foo; end
def fi(v)
  $log << :fi
  v
end
def fs(v) = v
fi(3)
fs("s")
try { opt(1, **1) }
try { opt(1, **1.5) }
try { opt(1, **"s") }
try { opt(1, **1r) }
try { opt(1, **2i) }
try { opt(1, **[1]) }
try { opt(1, **Foo.new) }
try { opt(1, x: 1, **1) }
try { opt(1, **fi(nil)) }
try { opt(1, **fi(2)) }
try { opt(1, **fs(nil)) }
try { two(1, **fi(nil)) }
try { two(1, **1) }
try { pr(1, **1) }
try { pr(1, **1r) }
try { pr(1, 2, **fi(nil)) }
try { pr(1, 2, **fs("t")) }
try { yo(1, **fi(nil)) { |x, y| [x, y] } }
try { Pos.new(1, **[1]).v }
try { Pos.new(1, **fi(nil)).v }
try { Plain.new(1, **1) }
try { send(:opt, 1, **"s") }
[Pos.new(0), Other.new].each do |r|
  try { r.g(1, **1) }
  try { r.g(1, **fs(nil)) }
  try { r.pr(1, **Foo.new) }
end
p $log

# constructors
try { Base.new(**nil).v }
try { Base.new(**nil, b: 2).v }
try { Sub.new(**true).v }
try { Point.new(**nil) }
try { Point.new(**true) }
try { Point.new(x: 1, **false) }
try { Opts.new(**nil) }
try { Opts.new(**true) }
try { Plain.new(**false) }
