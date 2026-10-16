# A boxed value that is a String or a Class the analysis cannot name
# (`1.class`, a Struct) calls String#split: a module's class method of the
# name (Shellwords.split) is no arm when the program only calls that module
# and never holds it as a value. The call's type left that arm out, but the
# dispatch still emitted it, putting the module's Array into the slot typed
# for String#split's, and the C did not compile.
require "shellwords"
require "optparse"

h = {a: "x,y", b: 1.class}
p h[:a].split(",")

Pair = Struct.new(:l, :r)
g = {a: "1;2", b: Pair}
p g[:a].split(";")
p g[:b].new(1, 2).r

OptionParser.new { |o| o.on("--x V", Array) { |v| p v } }.parse!(["--x", "a,b"])
p Shellwords.split("a 'b c'")

module Splitter
  def self.split(s) = [:module, s]
end
k = {a: "p-q", m: Splitter, b: 1.class}
p k[:a].split("-")
p k[:m].split("r")
