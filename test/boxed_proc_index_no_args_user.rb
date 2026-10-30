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
