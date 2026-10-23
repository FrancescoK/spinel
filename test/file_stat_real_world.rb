# spinel: gc-stress
require "tmpdir"
root = Process.uid == 0
Dir.mktmpdir("spinel_stat_real_world") do |dir|
  path = File.join(dir, "f")
  File.write(path, "")
  # the owner's bits decide the real tests, before the other bits
  [0644, 0600, 0666, 0007, 0604, 0602].each do |m|
    File.chmod(m, path)
    st = File.stat(path)
    p [m.to_s(8), st.readable_real? == (root || m & 0400 != 0),
       st.writable_real? == (root || m & 0200 != 0),
       st.world_readable?, st.world_writable?]
  end
  # the setuid and sticky bits are not part of the answer
  File.chmod(04755, path)
  p File.stat(path).world_readable?
  d = File.join(dir, "d")
  Dir.mkdir(d)
  File.chmod(0757, d)
  st = File.stat(d)
  p [st.readable_real?, st.writable_real?, st.world_readable?, st.world_writable?]
  # a symlink: stat answers for its target, lstat for the link
  File.chmod(0600, path)
  l = File.join(dir, "l")
  File.symlink(path, l)
  p File.stat(l).world_readable?
  lm = File.lstat(l).mode & 0777
  p File.lstat(l).world_readable? == (lm & 4 != 0 ? lm : nil)
  # nil, read through &., and a Stat out of a mixed Array
  n = ARGV.empty? ? nil : st
  p n&.world_readable?, n&.world_writable?, n&.readable_real?, n&.writable_real?
  w = File.stat(path).world_writable?
  p w.nil?, (w || 1) + 1
  b = [st, 1][0]
  p [b.readable_real?, b.writable_real?, b.world_readable?, b.world_writable?]
  names = %w[readable_real? writable_real? world_readable? world_writable?]
  p names.map { |m| st.respond_to?(m) }, names.map { |m| b.respond_to?(m) }
  File.open(path) { |f| p names.map { |m| f.respond_to?(m) } }
end
