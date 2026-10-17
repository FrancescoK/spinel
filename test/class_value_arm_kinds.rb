# Which class methods a boxed String-or-Class value's `split` arms, and the
# call's type takes in: a module's own `def self.split` no box holds is
# left out (a String's split keeps its Array of Strings), while a class's,
# one copied into a module from a module it extends, and a reopened
# Class's answer for the class values that reach them. The dispatch and
# the type decide by one rule, so the slot holds every arm's answer.
require "shellwords"

class Splitter
  def self.split(s) = [:class, s]
end
module Mix
  def split(s) = [:mix, s]
end
module Host
  extend Mix
end
module Own
  def self.split(s) = [:own, s]
end
class Class
  def tagged(s) = [:cls, name, s]
end

p Splitter.split("a"), Host.split("b"), Own.split("c"), Shellwords.split("d e")

h = {a: "x,y", b: 1.class}
p h[:a].split(",")

k = {a: "p-q", c: Splitter, m: Host}
p k[:a].split("-")
p k[:c].split("r")
p k[:m].split("s")

v = [String, Integer, 1.class][1]
p v.tagged("t")
