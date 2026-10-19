# Calls on a boxed receiver that may be an Array subclass instance, from
# several sites sharing one dispatch: the subclass's own method, a name the
# subclass leaves to Array, and the program's classes beside them.
class Bag < Array
  def describe = "bag of #{size}"
end
class Tags < Array
  def describe = "tags #{join(",")}"
end
class Aa; def describe = "aa"; def size = 10; end
class Bb; def describe = "bb"; def size = 20; end
class Cc; def describe = "cc"; def size = 30; end
class Dd; def describe = "dd"; def size = 40; end
class Ee; def describe = "ee"; def size = 50; end

def first_site(x) = x.describe
def second_site(x) = x.describe
def sized(x) = x.size

b = Bag.new
b.push(1); b.push(2)
t = Tags.new
t.push("x"); t.push("y"); t.push("z")
xs = [Aa.new, Bb.new, Cc.new, Dd.new, Ee.new, b, t]
xs.each { |x| puts first_site(x) }
xs.reverse.each { |x| puts second_site(x) }
puts xs.map { |x| sized(x) }.sum
puts xs.select { |x| x.is_a?(Array) }.map(&:describe).join(" / ")
