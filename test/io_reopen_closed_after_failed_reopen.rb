# Reopening a closed File after a reopen of it failed. The failed reopen
# released the closed handle's reservation without giving it a stream, so
# the handle was neither closed-and-released nor open, and the second
# reopen raised "stream closed in another thread".
require 'tmpdir'
Dir.mktmpdir do |dir|
  path = File.join(dir, "a.txt")
  File.write(path, "hello\n")
  f = File.open(path)
  f.close
  begin
    f.reopen(File.join(dir, "missing.txt"))
  rescue SystemCallError => e
    puts e.class
  end
  p f.closed?
  f.reopen(path, "r")
  p f.closed?
  p f.gets
  f.close
end
