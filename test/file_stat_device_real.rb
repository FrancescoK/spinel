# spinel: gc-stress
require "tmpdir"
st = File.stat(Dir.tmpdir)
p [st.dev_major.nil? || st.dev_major.is_a?(Integer),
   st.dev_minor.nil? || st.dev_minor.is_a?(Integer), st.executable_real?]
Dir.mktmpdir("spinel_stat_device_real") do |dir|
  path = File.join(dir, "f")
  File.write(path, "")
  File.chmod(0601, path)
  p File.stat(path).executable_real? == (Process.uid == 0)
  File.chmod(0700, path)
  p File.stat(path).executable_real?
end
m = ARGV.empty? ? nil : st
p m&.dev_major, m&.dev_minor
b = [st, 1][0]
p b.dev_major == st.dev_major, b.dev_minor == st.dev_minor, b.executable_real? == st.executable_real?
