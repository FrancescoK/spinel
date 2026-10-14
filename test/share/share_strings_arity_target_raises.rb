# A boxed receiver's call reaches a program method of the same name, here a
# module's own split, only to raise ArgumentError when that method cannot
# take the call's arguments (four positional ones for two given, or a
# required keyword not given). The call then answers what the String's
# split does: a new Array of new Strings, its first element a new String.
# Kept beside a String changed through another name, it is a new handle, a
# change through it showing through its other names. Through a splat the
# count is known only at run time and the module's split stays a target;
# the box holding the module raises.
$all = []
b = +"buf"; $all << b; b << "!"
module PB
  def self.split(s, keys, values, present) = keys << s
end
module KW
  def self.split(s, k:) = [s]
end
def lookup(string)
  head = string.split(";", 2)[0]
  $all << head
  head
end
h = lookup(ARGV.size > 0 ? 1 : +"text/html; charset=utf-8")
h << "?"
p h, PB.split("a", [], [], true)
x = ARGV.size > 0 ? KW : +"a;b"
k = x.split(";", 2)[0]
$all << k
k << "?"
p k, KW.split("z", k: 1)
args = [";", 2]
y = ARGV.size > 0 ? PB : +"c;d"
c = y.split(*args)[0]
$all << c
c << "?"
p c
[PB, +"e;f"].each do |z|
  e = z.split(";", 2)[0]
  $all << e
  e << "?"
rescue ArgumentError => err
  p err.message
end
p $all
