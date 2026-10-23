# A module prepended to Array answers shuffle in the builtin's place: the
# element read of its answer is the global's own String, so the change
# made through it shows in the global.
$g = String.new("glob")
module Rev
  def shuffle = [$g]
end
Array.prepend(Rev)
w = "a b".split.shuffle[0]
w << "!"
p $g
