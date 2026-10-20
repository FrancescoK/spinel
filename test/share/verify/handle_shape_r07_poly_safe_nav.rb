# The same through `&.`: a mutator called on the answer of a method that
# answers its argument, beside one that answers nil, changes the argument
# when the first is the receiver, and nothing when the second is.
class PA; def pick(t) = t; end
class PB; def pick(t) = nil; end
s = +"abc"
[PA.new, PB.new].each do |px|
  px.pick(s)&.<<("!")
  p s
end
