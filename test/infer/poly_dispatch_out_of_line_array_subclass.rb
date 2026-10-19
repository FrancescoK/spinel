# A boxed receiver's dispatch is one shared out-of-line function in a
# program that also subclasses Array, whose dispatch key reads the
# receiver's Array subclass first.
class Bag < Array; end
class Aa; def describe = "aa"; end
class Bb; def describe = "bb"; end
class Cc; def describe = "cc"; end
class Dd; def describe = "dd"; end
class Ee; def describe = "ee"; end
class Ff; def describe = "ff"; end
class Gg; def describe = "gg"; end
xs = [Aa.new, Bb.new, Cc.new, Dd.new, Ee.new, Ff.new, Gg.new]
xs.each { |x| puts x.describe }
puts xs[ARGV.size].describe
p Bag.new.push(1).size
