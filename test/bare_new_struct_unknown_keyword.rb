# A bare `new(...)` or a `self.new(...)` in a class method of a Data or
# Struct checks its arguments as `S.new(...)` does: a keyword that names no
# member, a Data member no keyword or positional names, positionals into a
# keyword_init Struct, and more positionals than members raise CRuby's
# ArgumentError once every argument has run. Both built the value, dropping
# the key or the argument and leaving the member nil; `self.new` left a typed
# member no keyword names as its zero, where CRuby leaves it nil. A bare
# `new(*a)` spreads the array across the members, where it failed to build.
def try
  p yield
rescue ArgumentError => e
  p [e.class, e.message]
end

$log = []
def v(x) = ($log << x; x)
H = { y: 2, q: 3 }

K = Struct.new(:a, :b, keyword_init: true) do
  def self.one = new(z: 1)
  def self.two = new(a: 1, z: 2, w: 3)
  def self.ordered = new(a: v(1), z: v(2))
  def self.via_self = self.new(a: 1, q: 2)
  def self.via_send = send(:new, a: 1, q: 2)
  def self.in_block = [1].map { |i| new(a: i, y: 2) }
  def self.ok = new(b: 4, a: 3)
  def self.partial = self.new(a: 5)
  def self.positional = new(v(3))
  class << self
    def singleton = new(a: 2, q: 3)
  end
end
try { K.one }
try { K.two }
try { K.ordered }
p $log
try { K.via_self }
try { K.via_send }
try { K.in_block }
try { K.singleton }
try { K.ok }
try { K.partial }
p K.partial.b.nil?
try { K.positional }

# inherited, and built as the subclass
class Sub < K; end
try { Sub.one }
try { Sub.ok }

# a plain Struct called with keywords alone takes them as keyword_init does
P = Struct.new(:a, :b) do
  def self.bad = new(a: 1, zz: 2)
  def self.via_self = self.new(zz: 2)
  def self.ok = new(b: 5)
  def self.too_many = new(v(4), v(5), v(6))
  def self.short = new(1)
  def self.spread(x) = new(*x)
  def self.spread_after(x) = new(0, *x)
end
try { P.bad }
try { P.via_self }
try { P.ok }
try { P.too_many }
try { P.short }
try { P.spread([1]) }
try { P.spread([1, 2, 3]) }
try { P.spread_after([1]) }
p $log

# Data names the missing members first, then the unknown keys
D = Data.define(:x, :y) do
  def self.unknown_only = new(z: 3)
  def self.missing = new(x: 1)
  def self.missing_and_unknown = new(x: 1, z: 2)
  def self.unknown = new(x: 1, y: 2, z: 3)
  def self.unknowns = new(x: 1, y: 2, z: 3, w: 4)
  def self.repeated = new(x: 1, y: 2, z: 3, z: 4)
  def self.via_self = self.new(x: 1, y: 2, z: 3)
  def self.via_self_missing = self.new(y: 2)
  def self.splat = new(x: 1, **H)
  def self.ok = new(y: 2, x: 1)
  def self.none = new
  def self.one = new(v(7))
  def self.three = new(1, 2, 3)
  def self.pair = new(1, 2)
  def self.spread(x) = new(*x)
end
try { D.unknown_only }
try { D.missing }
try { D.missing_and_unknown }
try { D.unknown }
try { D.unknowns }
try { D.repeated }
try { D.via_self }
try { D.via_self_missing }
try { D.splat }
try { D.ok }
try { D.none }
try { D.one }
try { D.three }
try { D.pair }
try { D.spread([1, 2]) }
p $log

# a keyword_init: false Struct keeps the keywords as its first member
F = Struct.new(:a, keyword_init: false) do
  def self.f = new(z: 1)
end
try { F.f }
