class K
  @@c = +""
  def self.add(x) = (@@c << x)
  def self.c = @@c
end
c = K.c
K.add("a")
p c, c.equal?(K.c)
