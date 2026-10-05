# File#size on a boxed handle when a USER class of the program also owns
# `size`: the boxed dispatch is then the per-class chain (the user arms, the
# String and Array kinds), whose default arm raised for the File the same
# program keeps beside those objects in one Hash. A handle now takes the
# runtime's own File-or-IO answer inside that chain: a File answers, an IO
# raises CRuby's NoMethodError. Both modes.
class Memory
  def initialize(n) = @n = n
  def size = @n
end
path = "/tmp/sp_file_size_beside_user_size_#{Process.pid}.txt"
File.write(path, "hello")
class Host
  def initialize(path)
    @fds = { 0 => $stdin, 1 => $stdout, 3 => File.open(path, "r+"), 4 => Memory.new(9) }
  end
  def size_of(fd) = @fds[fd].size
  def trunc(fd, n) = @fds[fd].truncate(n)
  def allocate(fd, needed)
    io = @fds[fd]
    io.truncate(needed) if needed > io.size
    io.size
  end
end
h = Host.new(path)
p h.size_of(4)
p h.size_of(3)
p h.trunc(3, 2)
p h.size_of(3)
p h.allocate(3, 8)
p File.read(path).size
begin
  h.size_of(1)
rescue NoMethodError => e
  puts e.message.sub(/:0x[0-9a-f]+/, "")
end
p [Memory.new(1), "ab", [1, 2, 3], :sym].map(&:size)
