# `x == nil` on an untyped x asks a program object's own `==`, whatever it
# answers (`def ==(o) = nil` keeps its nil); `x != nil` asks its own `!=`,
# else negates its `==`.
class Always
  def ==(o) = true
end

class Never
  def ==(o) = nil
end

class Ver
  include Comparable
  attr_reader :n
  def initialize(n) = @n = n
  def <=>(o) = o.is_a?(Ver) ? n <=> o.n : nil
end

class OwnNe
  def ==(o) = true
  def !=(o) = :own
end

class Plain; end

def eq(r) = r == nil
def ne(r) = (r != nil) ? :ne : :eq

[Always.new, Never.new, Ver.new(1), OwnNe.new, Plain.new, nil, 1, "s", [1]].each do |v|
  p [v.class, eq(v), ne(v)]
end

def or_else(r) = r == nil || :fallback
p or_else(Never.new)
p or_else(Always.new)
p or_else(nil)
p or_else(3)
