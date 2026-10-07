# Flag-only: the default build answers these too; under --share-strings
# they were refused ("a typed String container cannot hold the shared
# handle", "a String held by a block parameter ...").
# A String mutator's name called on a boxed value changes a String in place
# only when it can be a String's call. An index write no String takes (a
# Symbol index, a value of another class) is a store, whatever the
# receiver; and through a box that cannot hold a String (one bound from an
# element of an Array or Hash literal holding none), a Struct member write
# (`o["x"] = v`, `o[0] = v`), a Hash store or an Array append is one too.
# Such a store shares no String the program holds elsewhere.
S = Struct.new(:x)

# a Struct in a box bound from a literal's element
def show(o)
  p ["value", o.x].compact
end
o = [S.new("value"), 0][0]
o[:x] = "value"
show(o)
o["x"] = "other"
p ["other", o.x]
o[0] = "third"
p [o.x, o[0], o[-1], "third"]

# a Symbol index through a parameter and a block parameter
def store(t, v)
  t[:x] = v
  t
end
p store(S.new("a"), "b").x
p store({ x: "a" }, "c")
keep = ->(&blk) { blk }
writer = keep.call { |acc| acc[:k] = "kept" }
h = { z: "zero" }
writer.call(h)
p [h, "kept"]
s = S.new("before")
[s].each { |m| m[:x] = "after" }
p [s.x, "after"]

# a box of Arrays and Hashes appended to and stored into
c = [[+"one"], { k: "v" }][0]
c << "two"
c[0] = "three"
p [c, "two", "three"]
d = [{ k: "v" }, [1]][0]
d[:k2] = "w"
p [d, "w"]
p S.new("each").to_a
