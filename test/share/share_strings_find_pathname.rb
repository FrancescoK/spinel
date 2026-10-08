# A reverse traversal binds boxed directory entries into the String slot
# that a reassigned block parameter and an inlined yield share.
# spinel: gc-minor
require 'find'
require 'pathname'
require 'tmpdir'

def walk_path(root)
  Find.find(Pathname.new(root)) { |path| p path.sub(root, 'ROOT') }
end

root = File.join(Dir.tmpdir, "spinel_find_handle_#{Process.pid}")
Dir.mkdir(root)
Dir.mkdir(File.join(root, 'dir'))
File.write(File.join(root, 'dir', 'a'), 'a')
File.write(File.join(root, 'b'), 'b')
walk_path(root)
File.delete(File.join(root, 'dir', 'a'))
File.delete(File.join(root, 'b'))
Dir.rmdir(File.join(root, 'dir'))
Dir.rmdir(root)
