# find_index(v) { } answers the value form unless an Enumerable reopen of
# the program defines find_index. A find_index of another class, or of a
# module named Enumerable inside another namespace, does not count.

class U
  def find_index(v) = yield(v)
end

module Foo
  module Enumerable
    def find_index(v) = yield(v)
  end
end

p [5, 6].each.find_index(6) { |x| x + 1 }
p (1..5).find_index(3) { |x| x * 7 }
p ("a".."c").find_index("b") { |x| x * 2 }
p [5, 6].find_index(6) { |x| x + 1 }
p U.new.find_index(3) { |x| x * 7 }
