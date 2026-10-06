# K.g answers the class variable's String itself, which is s. The answer
# was a copy and s stayed "abc": refused, not compiled wrong.
class K
  def self.set(v) = (@@g = v)
  def self.g = @@g
end
s = +"abc"
K.set(s)
K.g << "?"
p s
