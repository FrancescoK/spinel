# A File::Stat read out of a container answers its predicates as a typed
# File::Stat does, where each raised NoMethodError.
path = "/tmp/spinel_boxed_statp_#{Process.pid}"
File.write(path, "hello")
st = [File.stat(path), 0][0]
p [st.file?, st.directory?, st.symlink?, st.socket?]
p [st.readable?, st.writable?, st.executable?]
p [st.pipe?, st.blockdev?, st.chardev?]
p st.size?
p [st.owned?, st.setuid?, st.setgid?, st.sticky?]
d = [File.stat("/tmp"), 0][0]
p [d.directory?, d.file?]
# a File is no File::Stat: it has none of these
f = [File.open(path), 0][0]
p (f.file? rescue [$!.class, $!.message])
f.close
File.write(path, "")
p [File.stat(path), 0][0].size?
File.delete(path)
