# spinel: not-cruby
# Missing hooks preserve master on the existing IO reopening route.
require "tmpdir"
class File
  private def x = 1
  def method_missing(name, *args) = "mm:#{name}"
  def probe = (self).x
end
path = File.join(Dir.tmpdir, "spinel_ignvis3_missing_scope_io")
begin
  File.open(path, "w") { |f| p f.probe }
ensure
  File.unlink(path) if File.exist?(path)
end
