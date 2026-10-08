# Each computed operand survives allocation by the next operand, including
# setup for an Array argument and the boxed File.join route.
# spinel: gc-minor
require "tmpdir"
i = 7
a = [1, 2]
p File.join(a.map(&:to_s).join("-"), "x#{i}")
p File.join(a.map(&:to_s).join("-"), "x#{i}", "y#{i}")
p File.join(a.map(&:to_s).join("-"), ["x#{i}", "y#{i}"])
p File.join([a.map(&:to_s).join("-")], "x#{i}")
p File.basename(File.join(Dir.tmpdir, "x#{i}"))
p File.join
p File.join("one")
p File.join("one", "two")
p "abcabc".delete(["a", "b"].join, "a#{i}")
p "abcabc".count(["a", "b"].join, "a#{i}")
p "aaabbcc".squeeze(["a", "b"].join, "a#{i}")
# The base exists; realdirpath permits its last component to be absent.
p File.basename(File.realdirpath("mfix#{i}", [Dir.tmpdir].join))
# Key-list builtins use boxed compound literals for the same shape.
h = [{"ab" => {"x7" => 1}, "x7" => 2}, 0][0]
p h.dig(["a", "b"].join, "x#{i}")
p h.slice(["a", "b"].join, "x#{i}")
Row = Struct.new(:data)
r = Row.new({"ab" => {"x7" => 3}})
p r.dig(:data, ["a", "b"].join, "x#{i}")
k = :data
p r.dig(k, ["a", "b"].join, "x#{i}")
p [1, 2].dig(0, 0) rescue p $!.class
