# The two String representations refused this program; with one it answers as CRuby.
# A module prepended to Array may answer shuffle in the builtin's place: an
# element read of it over a new String Array, kept and changed, stays
# refused.
$g = String.new("glob")
module Rev
  def shuffle = [$g]
end
Array.prepend(Rev)
w = "a b".split.shuffle[0]
w << "!"
p $g
