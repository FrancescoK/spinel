# Marshal.dump answers a new String, one no other name holds, so under
# --share-strings it can be named twice and changed in place, as
# ActiveSupport's cache entries do with a serialized value. The call had no
# share fact, so the String was of unknown origin, and handing it on was
# refused as a copy.
value = [1, "a", :b]
serialized = Marshal.dump(value)
alias_of = serialized
alias_of << "!"
p serialized.bytesize == alias_of.bytesize, serialized.equal?(alias_of)
p Marshal.load(serialized.chomp("!")) == value

def dump(entry)
  "\x00".b + Marshal.dump(entry)
end
out = dump({k: 1})
copy = out
copy << "x"
p out.bytesize, copy.equal?(out)
