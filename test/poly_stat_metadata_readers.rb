# spinel: gc-stress
# A File::Stat read back out of a container answers ftype, as a typed one
# does; a File handle there has no ftype.
require "tmpdir"
def att(name)
  yield
rescue NoMethodError => e
  p [name, e.class, e.message[0, 60]]
end

class Entry
  def ftype; "custom"; end
end

path = File.join(Dir.tmpdir, "spinel_stat_container_#{Process.pid}.txt")
begin
  File.write(path, "hello")
  st = [File.stat(path)][0]
  p [st.size, st.ftype, st.file?, st.directory?, st.mtime.is_a?(Time)]
  att(:dir) { p [File.stat(Dir.tmpdir), 0][0].ftype }
  att(:lstat) { p [File.lstat(path), 0][0].ftype }
  att(:hash) { p({ s: File.stat(path) }[:s].ftype) }
  [File.stat(path), Entry.new].each { |x| p x.ftype }
  File.open(path) do |f|
    att(:file) { p [f, 0][0].ftype }
    att(:file_mtime) { p [f, 0][0].mtime.is_a?(Time) }
    att(:typed_file) { p f.ftype }
  end
  att(:int) { p [3, "x"][0].ftype }
ensure
  File.delete(path) if File.exist?(path)
end
