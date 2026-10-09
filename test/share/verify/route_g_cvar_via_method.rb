class K
  def self.set(v) = (@@g = v)
  def self.g = @@g
end
s = +"abc"
K.set(s)
K.g << "?"
p s
