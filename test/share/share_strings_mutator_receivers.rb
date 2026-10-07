# Flag-only: each name below holds its own copy without the flag, and with
# it a String is shared only when a change in place can reach it. A call of
# a String mutator's name through a boxed or untyped receiver counted as a
# change of a String whatever the receiver held, and the String literals
# whose class it met were refused ("a typed String container cannot hold
# the shared handle yet"). It counts now only when a String can make the
# call (an argument a String takes as a String is not of another class) on
# a receiver that can be a String (a variable written a String, or one
# whose values are not all seen).

# a lambda's parameter: concat of an Array, insert of an Integer
s = ->(acc) { acc.concat(["x"]) }
r = s.call([]); p r
w = ->(acc) { acc.insert(0, 5) }
p w.call([])

# what the walk does not follow (a proc's call) meets a literal's Strings,
# and the receivers below: a Hash through a method's parameter, written by
# a Symbol index and a nil value; a box written an Array and an Integer
keep = proc { |a| a }
p keep.call(["e", "f"])
def put(h, k) = (h[:k] = k; h[:n] = nil; h)
p put(keep.call({a: 1}), "v")
q = ARGV.empty? ? [0] : 1
keep.call(q)
q << "z"
p q

# still shared: a box written a String, in a block too, and one appended
# an Integer (a codepoint)
x = ARGV.empty? ? +"s" : [1]
y = x
x << "t"
p y
b = [1]
[1].each { b = +"b" }
c = b
b << "c"
p c
d = [+"d", 1][0]
e = d
d << 101
p e
