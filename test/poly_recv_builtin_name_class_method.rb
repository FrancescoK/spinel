# A boxed receiver that holds a String or a Class reaches a class method of
# the name only for a class it can hold: Shellwords.split (and Foo.split,
# Foo.uniq) are no arms of `h[:a].split` when the Hash's values are a String
# and Integer, and their answers do not widen the String's.
require 'shellwords'

module Foo
  def self.split(x) = [1, x]
  def self.uniq = :foo
end

h = {a: "x,y", b: Integer}
p h[:a].split(",")
p h[:a].split(",").map(&:upcase)
begin
  h[:b].split(",")
rescue NoMethodError => e
  puts e.message
end

g = {a: [1, 1, 2], b: String}
p g[:a].uniq

# a module that is one of the values keeps its arm
module Bar
  def self.split(x) = ["bar", x]
end
k = {a: "p,q", b: Bar}
p k[:a].split(",")
p k[:b].split(",")

# a subclass held as a value reaches its parent's class method
class Base
  def self.split(x) = ["base", x]
end
class Sub < Base; end
s = {a: "m,n", b: Sub}
p s[:a].split(",")
p s[:b].split(",")
