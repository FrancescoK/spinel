# An empty Array literal given to a builtin method of an Array subclass
# instance is built as that instance's Array kind, as for a plain Array.
class MyA < Array; end
x = MyA.new([1])
p x.concat([])
p MyA.new(["s"]).concat([])
p MyA.new([1]).concat([], [2])
p MyA.new([1]) + []
p MyA.new([1.5]) - []
p MyA.new([1]) | []
p MyA.new([1]) & []
p MyA.new([1]).zip([])
p MyA.new([1]).replace([])
p MyA.new([1]) == []
p MyA.new([1]).push([])
p x.concat([]).class
