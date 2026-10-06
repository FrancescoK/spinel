# File#size and File#truncate on a BOXED handle. The two names cannot be
# served by the boxed-IO arm the other File methods take, since Float and
# Rational own #truncate and Array, Hash and String own #size, so the
# runtime dispatches on the handle itself: a handle File.open made answers
# as a File, and one that is an IO -- a standard stream, IO.for_fd, a pipe
# end -- raises CRuby's NoMethodError, whatever path it carries. The typed
# receiver and the other owners of the names keep their emitters.
path = "/tmp/sp_file_poly_size_truncate_#{Process.pid}.txt"
File.write(path, "hello world")

# typed
f = File.open(path, "r+")
p f.size
p f.truncate(8)
p File.read(path)
f.close

# boxed through a mixed Hash, read in another method
class Host
  def initialize
    @fds = { 0 => $stdin, 1 => $stdout, 2 => $stderr }
    @next = 3
  end
  def add(io)
    @fds[@next] = io
    @next += 1
    @next - 1
  end
  def size_of(fd) = @fds[fd].size
  def set_size(fd, n) = @fds[fd].truncate(n)
  def allocate(fd, needed)
    io = @fds[fd]
    io.truncate(needed) if needed > io.size
    io.size
  end
  def trunc0(fd) = @fds[fd].truncate
end
h = Host.new
fd = h.add(File.open(path, "r+"))
p h.size_of(fd)
p h.allocate(fd, 12)
p h.set_size(fd, 3)
p h.size_of(fd)
p File.read(path)

def msg(e) = e.message.sub(/:0x[0-9a-f]+/, "")
begin; h.size_of(1); rescue NoMethodError => e; puts msg(e); end
begin; h.set_size(1, 0); rescue NoMethodError => e; puts msg(e); end
r, w = IO.pipe
pfd = h.add(w)
begin; h.size_of(pfd); rescue NoMethodError => e; puts msg(e); end
begin; h.set_size(pfd, 0); rescue NoMethodError => e; puts msg(e); end
ffd = h.add(IO.for_fd(File.open(path, "r").fileno, autoclose: false))
begin; h.size_of(ffd); rescue NoMethodError => e; puts msg(e); end
begin; h.trunc0(fd); rescue ArgumentError => e; puts e.message; end

# the other owners of the names, boxed the same way
box = [3.7, 2.5, [1, 2], "abc", { a: 1 }]
p box[0].truncate
p box[1].truncate(0)
p box[2].size
p box[3].size
p box[4].size
p [3.7, 2.5].map { |x| x.truncate }
