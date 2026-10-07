# Under --share-strings the rule can convert a typed String Array to the
# poly Array only once the analysis is past its inference fixpoint: a call
# bound late joins the Array's elements with what the walk does not
# follow. Pathname's split_str (`out = []; ... out.push(part); out`)
# answered that Array through an sp_StrArray * return, and its callers'
# locals kept the typed form, so the C did not build. The conversion is a
# late widening the method's return and the locals written from it now
# follow. These lines are what it took for the requires to bring the
# conversion about.
if require 'strscan'
end
p((require('pathname') ? "y" : "n"))
p (require 'stringio' rescue nil)
if 1 > 0
end
def in_body
end
p Set.new([1, 2, 2]).size
parts = Pathname.new("/a/b/c").each_filename.to_a
kept = parts
p kept, parts.size
p Pathname.new("a/b/../c").cleanpath.to_s
