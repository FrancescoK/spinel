# A shared argument's byte snapshot must survive an allocating boxed receiver.
# The transforms also keep the String itself when a later argument mutates it.
require 'find'
require 'tmpdir'

root = File.join(Dir.tmpdir, "spinel_aa_transform_#{Process.pid}")
Dir.mkdir(root)
e = Find.find(root)
p e.first.sub(root, 'ROOT')
p e.next.gsub(root, 'ROOT')
p e.first.delete_prefix(root)
p e.first.delete_suffix(root)
letters = +'a'
saved_letters = [letters]
p e.first.squeeze(letters) == root.squeeze('a')
p e.first.tr(letters, 'x') == root.tr('a', 'x')
replacement = +'ROOT'
saved = [replacement]
p e.first.sub(root, replacement)
p e.first.gsub(root, replacement)
p e.first.tr(letters, replacement) == root.tr('a', 'ROOT')
p e.first.chomp(root)
p e.first.scan(root).first == root
format = +'a*'
saved_format = [format]
p e.first.unpack(format).first == root
p e.first.scrub(replacement) == root
p e.first.ljust(4096, root).length == 4096
p e.first.rjust(4096, root).length == 4096
p e.first.center(4096, root).length == 4096
p e.first.unpack1(format, offset: 0) == root
replacement << '!'
p saved
p saved_letters
p saved_format
Dir.rmdir(root)

def replacement_after_append(needle)
  needle << 'a'
  GC.start
  'x'
end

needle = +'a'
saved_needle = [needle]
text = [+'aabb', nil].first
p text.sub(needle, replacement_after_append(needle))
p saved_needle
