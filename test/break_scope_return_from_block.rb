# A `return` in a block that also breaks leaves the method through the
# iterator's break scope. Each such return took one entry of the fixed
# break stack and never gave it back, so a method called many times this
# way raised SystemStackError. The block runs inlined (an Array's find) or
# as a proc (the receiver is an Array, a Range or an object of the
# program's own only at run time), whose return longjmps to the method.
def label_of(words, bad)
  words.each do |w|
    break if w == bad
    return "got #{w}" if w.start_with?("b")
  end
  "none"
end

def kind_of_first(words)
  words.find do |w|
    break if w.empty?
    next if w.size < 2
    return w.to_sym if w.end_with?("y")
  end
  :none
end

class Lines
  def initialize(*ns) = @ns = ns
  def each(&blk) = @ns.each(&blk)
end

def first_wide(lines, limit)
  lines.each do |n|
    break if n > limit
    return n * 2 if n.even?
  end
  0
end

size = 0
500.times { size += label_of(%w[a b c], "z").size }
p size
kinds = []
500.times { kinds << kind_of_first(%w[a xy z]) }
p kinds.uniq, kinds.size
wide = 0
sources = [[1, 2, 3], Lines.new(3, 4), 1..4]
600.times { |i| wide += first_wide(sources[i % 3], 9) }
p wide
p label_of(%w[a z b], "z"), label_of(%w[c b], "z"), first_wide(1..9, 1), first_wide(Lines.new(3, 5), 9)
p kind_of_first(["ab", "", "zy"]), kind_of_first(%w[ab cd])
