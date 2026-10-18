# A String that another name changes in place, passed where the argument
# is a boxed value, is still a member of a String Array that a boxed
# receiver holds: the comparison reads its bytes.
require 'set'

def names(kind)
  case kind
  when :ary then %w[Group/LongName Other/Name]
  when :hash then { "Group/LongName" => 1 }
  when :set then Set["Group/LongName"]
  else ["Group/LongName", 1]
  end
end

def member?(coll, name)
  coll.include?(name)
end

s = +"Group/"
t = s
s << "LongName"

p member?(names(:ary), t)
p member?(names(:hash), t)
p member?(names(:set), t)
p member?(names(:poly), t)
p member?(names(:ary), "Other/Name")
p member?(names(:ary), :sym)
p member?(names(:ary), nil)

s << "X"
p member?(names(:ary), t)
p t
