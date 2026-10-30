# A late include into a core module (`module Enumerable; include M; end`,
# Active Support's to_json encoder) keeps its include as it was: the core
# module's methods are not the program's copies a guard entry can hold.
module Tagged
  def tagged = "tagged #{to_a.size}"
end
class Bag
  include Enumerable
  def each
    yield 1
    yield 2
  end
end
p Bag.new.to_a
module Enumerable
  include Tagged
end
p Bag.new.tagged, [1, 2, 3].each_slice(2).to_a
