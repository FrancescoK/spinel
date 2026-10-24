# A Data / Struct member read passed straight to Kernel#puts or #print, in a
# program where some class defines its own puts(str = "") and print(str = ""):
# the share plan holds the argument as a String handle, which the output
# path printed nothing for, and the compile refused the read.
class Writer
  def puts(str = "")
  end

  def print(str = "")
  end
end
Key = Data.define(:digest)
k = Key.new(digest: "abc")
puts k.digest
print k.digest, "\n"
n = Key.new(digest: nil)
puts n.digest
Pair = Struct.new(:digest)
puts Pair.new("def").digest
print n.digest
puts "|"
