# A method_missing hook in a reopened Object stands in for every object
# whose class lacks the name, nil and the other builtin values among them.
# Here each receiver can only be an object of a class that answers the
# name (a conditional, a case with an else, a method's parameter), never
# nil or another builtin value, so CRuby never routes the call to the hook
# and the fresh String each method answers keeps no other name.
$hooked = String.new("hooked")
class Object
  def method_missing(name, *args) = $hooked
end
class Fresh
  def token = String.new("fresh")
end
class Other
  def token = String.new("other")
end

def change(receiver)
  token = receiver.token
  saved = token
  token << "-param"
  saved
end

i = 0
while i < 2
  receiver = i == 0 ? Fresh.new : Other.new
  token = receiver.token
  saved = token
  token << "-ternary"
  puts saved

  receiver = case i
             when 0 then Other.new
             else Fresh.new
             end
  token = receiver.token
  saved = token
  token << "-case"
  puts saved

  if i == 0
    receiver = Fresh.new
  else
    receiver = Other.new
  end
  token = receiver.token
  saved = token
  token << "-if"
  puts saved

  i += 1
end
puts change(Fresh.new), change(Other.new)
puts $hooked
