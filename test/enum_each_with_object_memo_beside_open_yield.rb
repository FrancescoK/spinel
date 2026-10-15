# `each_with_object({}) { |s, h| h[s] = ... }` writes the memo, a Hash: no
# String is appended to. On a receiver that is a Rows here and an Array
# there, the Array arm goes to the Enumerable copy
# (`__enum_each_with_object__N`), which keeps its block as a proc, and the
# block's `h` is boxed (Rows#each_with_object is also given an Array memo).
# The memo rule that clears the block's second-parameter bit named the copy
# but also required that no method of its name exist, and the copy is one,
# so the block counted as the program's String appender and the yield in
# each_name, whose block is a proc read out of a slot, was refused (#9207).
class Rows
  def initialize(xs)
    @xs = xs
  end

  def each
    @xs.each { |x| yield x }
  end

  def each_with_object(memo)
    @xs.each { |x| yield x, memo }
    memo
  end
end

def each_name
  %w[x y].each { |s| yield s }
end

[Rows.new(%w[ab cd]), %w[ef]].each do |r|
  p(r.each_with_object({}) { |s, h| h[s] = s.upcase })
end
p(Rows.new(%w[gh]).each_with_object([]) { |s, a| a << s })

slots = [proc { |s| puts s }, 1]
each_name(&slots[0])
