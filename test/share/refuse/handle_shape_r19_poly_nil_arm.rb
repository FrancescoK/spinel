# Flag-only: under --share-strings this shape is refused rather than compiled
# handing on a copy of a String that another name holds.
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
