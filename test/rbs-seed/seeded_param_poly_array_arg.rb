# A poly array passed to a parameter the seed declares Array[String] or
# Array[Integer] is converted at the call, not bound as it is.
# spinel: rbs-seed-run
class A
  def initialize(t)
    @t = t
  end

  def t
    @t
  end
end

class C
  def t
    A.new("c")
  end
end

module Enc
  def self.join(values)
    "[" + values.map { |v| "\"#{v}\"" }.join(",") + "]"
  end

  def self.total(ns)
    ns.sum
  end
end

rows = [A.new("y"), A.new("x"), C.new]
puts Enc.join(rows.first(2).map { |r| r.t }.sort)
mixed = [1, "a", 2]
puts Enc.total(mixed.select { |v| v.is_a?(Integer) })
