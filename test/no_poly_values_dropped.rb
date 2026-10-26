# A value the program throws away does not make it a program with poly
# values (#8401): a loop's value, attr_reader's answer, an `if` with no
# else as a statement, and an #each that ends in its loop. Nor does a
# class with an ivar install the boxed-object inspect hook then, which
# pulled in every renderer. (infer-test checks the define and the hook.)
class Lines
  def initialize(n) = @n = n
  def each
    i = 0
    while i < @n
      yield i
      i += 1
    end
  end
end
class Candidate
  attr_reader :pct
  def initialize(pct) = @pct = pct
end
module Fn
  def self.run
    candidates = []
    Lines.new(4).each do |i|
      pct = i * 5
      candidates << Candidate.new(pct) if pct > 0
    end
    total = 0
    candidates.each { |c| total += c.pct }
    total
  end
end
puts Fn.run
