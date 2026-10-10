# A File::Stat read out of a container answers its size, mode, numeric fields
# and zero? as a typed File::Stat does, where each raised NoMethodError.
path = "/tmp/spinel_boxed_stat_#{Process.pid}"
File.write(path, "hello")
File.chmod(0644, path)   # the mode printed below, whatever the umask
st = [File.stat(path), 0][0]
p st.size
p st.nlink
p [st.ino, st.uid, st.gid, st.dev, st.blksize, st.blocks].all? { |n| n.is_a?(Integer) }
p st.mode.to_s(8)
p st.zero?
File.write(path, "")
p [File.stat(path), 0][0].zero?
File.delete(path)
# a class method of one of these names keeps its own answer
class Perm
  def self.rdev = :class_rdev
end
p [Perm, 0][0].rdev
# names other values answer keep their own arms
p [[1, 2, 3], 0][0].size
p [0, "s"][0].zero?
