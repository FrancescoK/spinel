# File.open's path stays a plain String even though StringIO.open keeps
# and changes its init argument. Calls that reach StringIO.open still
# share that argument, with or without a block and through a class value.
require "stringio"
require "tmpdir"

path = File.join(Dir.tmpdir, "spinel_open_targets_#{Process.pid}.txt")
File.open(path, "w") { |f| f.write("file") }
f = ::File.open(path, "r")
p f.read
f.close

init = +"old"
StringIO.open(init, "w") { |io| io.write(File.read(path)) }
p init

appended = +"more"
io = StringIO.open(appended, "a")
io.write("!")
p appended
io.close

klass = StringIO
indirect = +"before"
other = klass.open(indirect, "w")
other.write("after")
p indirect
other.close
File.delete(path)
