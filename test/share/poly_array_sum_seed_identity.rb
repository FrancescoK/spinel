# An empty sum returns its seed, including the shared String handle. A
# non-empty sum concatenates into a new String and leaves the seed alone.
class TextSeed
  def value = +"a" + "b"
end
class NumberSeed
  def value = 7
end
objects = [TextSeed.new, NumberSeed.new]
empty = []
r = empty.sum(objects[0].value)
q = r
q << "!"
p r

items = [1, "unused"].take(0)
seed = +"a" + "b"
result = items.sum(seed)
seed << "!"
p result

strings = ["x"].take(0)
seed2 = +"c"
result2 = strings.sum(seed2)
seed2 << "!"
p result2

seed3 = +"d"
result3 = [1].take(0).sum(seed3) { |x| x.to_s }
seed3 << "!"
p result3

hash = { a: 1 }
hash.clear
seed4 = +"e"
result4 = hash.sum(seed4) { |k, v| v.to_s }
seed4 << "!"
p result4

seed5 = +"f"
result5 = ["g"].sum(seed5)
seed5 << "!"
p [result5, seed5]
