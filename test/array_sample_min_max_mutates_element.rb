# sample, min and max answer one of the Array's own Strings, so a mutation
# through the result reaches the Array, as it does through [], first, last
# and fetch. They were not on the list of element reads, so the Array kept
# plain Strings and the append grew a copy.
a = [String.new("q")]
a.sample << "z"
p a

b = [String.new("u"), String.new("v")]
b.min << "1"
b.max << "2"
p b

c = [String.new("abc")]
c.sample.upcase!
p c

d = [String.new("x"), String.new("y")]
d.max.concat("!")
d.min.replace("w")
p d

# with a count they answer a new Array: its Strings are the same objects
e = [String.new("m")]
e.sample(1).first << "n"
e.min(1).first << "o"
p e
