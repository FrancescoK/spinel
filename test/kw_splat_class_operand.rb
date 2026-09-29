# A `**` operand whose value is a Class or Module: nil carries no keywords,
# and a class, having no #to_hash, is CRuby's TypeError naming Class or
# Module. A Class value holds nil as SP_CLASS_NIL (`BasicObject.superclass`),
# which the static judgment could not see: into a **kwrest the call was
# refused at compile time as a non-Symbol-keyed hash, and into named
# keywords a class bound as no keywords and raised nothing. Each probe goes
# through a **kwrest alone, named keywords, a keyword merged beside the
# operand, a method, a class method, `new`, a block, a Struct, a hash
# literal and a call refused for its count, with nil, a class and a module.
S = Struct.new(:z, keyword_init: true)
class K
  def initialize(z: 0, **kw) = (@z = z; @kw = kw)
  def show = [@z, @kw]
  def m(**kw) = kw
  def self.s(z: 1) = z
end
def f(**kw) = kw
def g(a: 0) = a
def h(a: 0, **kw) = [a, kw]
def one(a) = a
def y(c) = yield(**c)
def try(label)
  p [label, yield]
rescue TypeError, ArgumentError => e
  p [label, e.class, e.message]
end
def probe(cls)
  try(:rest) { f(**cls) }
  try(:named) { g(**cls) }
  try(:merged) { h(a: 1, **cls) }
  try(:method) { K.new.m(**cls) }
  try(:class_method) { K.s(**cls) }
  try(:new) { K.new(**cls).show }
  try(:block) { y(cls) { |a: 2| a } }
  try(:struct) { S.new(**cls) }
  try(:literal) { { **cls, w: 1 } }
  try(:refused) { one(1, 2, **cls) }
end
probe(BasicObject.superclass)
probe(String)
probe(Kernel)
probe(Integer.superclass)
try(:constant) { f(**Comparable) }
try(:superclass) { g(**Object.superclass.superclass) }
