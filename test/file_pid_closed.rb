# File#pid on a closed File raises IOError, as CRuby does, where it
# answered nil; an open File still answers nil.
path = "/tmp/spinel_pid_closed_#{Process.pid}"
File.write(path, "abc")
f = File.open(path)
p f.pid
f.close
p (f.pid rescue [$!.class, $!.message])
File.delete(path)
