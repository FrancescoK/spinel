# The two String representations refused this program; with one it answers as CRuby.
# Flag-only: under --share-strings this shape is refused rather than compiled
# handing on a copy of a String that another name holds.
class K
  def self.set(s, c)
    @@a, @@b = (c ? s : +"q"), s
  end
  def self.get = [@@a, @@b]
end
c = ARGV.size == 0
s = +"abc"
K.set(s, c)
K.get[0] << "!"
p s, K.get, K.get[0].equal?(s)
