# instance_variable_set of a String into an ivar that is also mutated in
# place through its reader, which nothing but instance_variable_set writes,
# is not yet shared by reference: refused, not copied.
# spinel: reject-share
class Plain
  def text = @text
end
o = Plain.new
s = +"abc"
o.instance_variable_set(:@text, s)
s << "!"
o.text << "?"
p o.text, s
