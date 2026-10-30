# `x[]` with no argument on a boxed value, beside a program class with a `[]`
# of its own: the class's method answers for its objects, and a Proc or a
# Method is called.

class Table
  def [](k = :first) = "table #{k}"
end

def eight = 8

vals = [-> { 5 }, Table.new, method(:eight), proc { :pr }]
vals.each { |v| p v[] }
p vals[1][:x]

# a Method beside the class, with no Proc in the program's slot
def nine = 9
ms = [method(:nine), Table.new]
p ms[0][], ms[1][]

# a class with a class method of the name, beside a Proc and a Method: the
# class value takes its class method, and the Proc or the Method is called
class Lookup
  def self.[](k = :first) = "lookup #{k}"
end
class Job
  def self.call(x = 1) = "job #{x}"
end
ls = [Lookup, -> { 6 }, method(:nine)]
ls.each { |v| p v[] }
p ls[0][:y]
js = [Job, -> { 7 }, method(:nine)]
js.each { |v| p v.call }
p js[0].call(2)

# a class method of the name that nothing calls leaves the Proc's call alone
class Unused
  def self.[](k = :first) = "unused #{k}"
  def self.call = "unused"
end
us = [-> { 8 }, method(:nine)]
p us[0][], us[0].call, us[1][], us[1].call
