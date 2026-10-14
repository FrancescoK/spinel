# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class PA; def pick(t) = t; end
class PC; def pick(t) = "lit"; end
s = +"abc"
[PA.new, PC.new].each do |px|
  begin
    px.pick(s) << "!"
  rescue FrozenError => e
    p e.class
  end
end
p s
