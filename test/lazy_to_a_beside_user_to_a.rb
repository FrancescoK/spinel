# A lazy pipeline's to_a, force or first(n) answers the Lazy's Array even
# where the program defines a to_a of its own (ActiveRecord::Relation does,
# in every Rails app). Inside a mixed Array literal the result was pushed
# unboxed and the C did not build (#9137).
class Rel
  def initialize
    @rows = [1]
  end

  def to_a
    @rows.dup
  end
end

def lazily
  lazy = [1, 2, 3].lazy
  [lazy.select { |x| x.odd? }.to_a, lazy.map { |x| x + 1 }.first]
end

def more
  src = [4, 5, 6, 7].lazy
  kept = src.reject(&:even?)
  [kept.to_a, src.map { |x| x * 2 }.force, src.select(&:even?).first(1), { k: kept.force }]
end

p Rel.new.to_a
p lazily
p more
