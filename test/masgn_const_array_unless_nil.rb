# A multiple assignment to instance variables from a constant Array of a
# known length, or a choice of such arrays: a variable whose position lies
# within every array it can come from is never nil, one past the end of any
# of them is. Chosen by `unless`, by an `elsif` ladder or by an arm of
# several statements, the answers are CRuby's.
SHORT = [1, 2]
FULL = [3, 4, 5]
OTHER = [6, 7, 8]

class ByUnless
  def initialize(c)
    @a, @b, @c = unless c then FULL else SHORT end
  end
  def vals = [@a, @b, @c]
  def total = @a + @b
end

class ByElsif
  def initialize(n)
    @a, @b, @c = if n == 0 then FULL elsif n == 1 then SHORT else OTHER end
  end
  def vals = [@a, @b, @c]
  def total = @a + @b
end

class BySequence
  def initialize(n)
    @a, @b, @c = if n == 0 then FULL else (n += 1; SHORT) end
  end
  def vals = [@a, @b, @c]
  def total = @a + @b
end

[true, false].each do |c|
  o = ByUnless.new(c)
  p o.vals, o.total
end
[0, 1, 2].each do |n|
  o = ByElsif.new(n)
  p o.vals, o.total
end
[0, 1].each do |n|
  o = BySequence.new(n)
  p o.vals, o.total
end
