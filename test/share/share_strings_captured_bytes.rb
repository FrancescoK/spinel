# A shared String's byte snapshot must survive allocation of the cell a
# closure captures. Repeating the call also checks a fresh second argument.
# spinel: gc-minor
require 'find'
require 'tmpdir'

def captured_walk(root, start)
  Find.find(start) { |path| puts path.sub(root, 'ROOT') }
end

root = File.join(Dir.tmpdir, "spinel_captured_bytes_#{Process.pid}")
Dir.mkdir(root)
File.write(File.join(root, 'a'), 'a')
captured_walk(root, root)
captured_walk(root, "#{root}/")
File.delete(File.join(root, 'a'))
Dir.rmdir(root)
