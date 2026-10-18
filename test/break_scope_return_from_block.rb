# A `return` in a block that also breaks leaves the method through the
# iterator's break scope. Each such return took one entry of the fixed
# break stack and never gave it back, so a method called many times this
# way raised SystemStackError.
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

size = 0
500.times { size += label_of(%w[a b c], "z").size }
p size
kinds = []
500.times { kinds << kind_of_first(%w[a xy z]) }
p kinds.uniq, kinds.size
p label_of(%w[a z b], "z"), label_of(%w[c b], "z")
p kind_of_first(["ab", "", "zy"]), kind_of_first(%w[ab cd])
