# A method that answers its argument beside one that answers nil: the
# change through the answer reaches the argument when the first is the
# receiver, and raises NoMethodError when the second is.
class PA; def pick(t) = t; end
class PB; def pick(t) = nil; end
s = +"abc"
[PA.new, PB.new].each do |px|
  begin
    px.pick(s) << "!"
  rescue NoMethodError => e
    p e.class
  end
end
p s
