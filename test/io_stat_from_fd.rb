# Ruby has no File.fstat / IO.fstat; the way to a File::Stat from a descriptor
# is IO.new(fd).stat, which needed three things. IO.new(fd) is the descriptor
# form of IO.for_fd. A handle opened that way has no path, so its stat has to
# come from fstat(2) rather than from stat(path). And the stat accessors were
# gated on the receiver still spelling `sp_file_stat_handle(...)`, so they were
# lost the moment the stat was stored in a local.
path = "/tmp/spinel_io_stat_from_fd_#{Process.pid}.txt"
File.write(path, "hello")

f = File.open(path)
st = f.stat
p st.size
p st.mode.class
p st.file?
p st.directory?
p st.ftype

# through the descriptor, with no path behind it
io = IO.new(f.fileno)
p io.stat.size
p io.stat.ftype

fd_st = io.stat
p fd_st.size
p fd_st.mode.class

# a directory handle still answers by path
d = File.open("/tmp")
p d.stat.directory?
p d.stat.file?
d.close

f.close
File.delete(path)
puts "ok"
