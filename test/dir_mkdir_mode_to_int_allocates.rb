# spinel: gc-stress
require "tmpdir"
# Dir.mkdir(path, mode) converts the mode after it has the path: a mode
# whose #to_int allocates runs while the path built for the call is held
# only by the call, which keeps it alive across the conversion.
class Mode
  def initialize(m) = @m = m
  def to_int
    @log = (1..50).map { |i| "step #{i}" }
    @m
  end
end
base = File.join(Dir.tmpdir, "sp_dir_mkdir_to_int_#{Process.pid}")
mask = File.umask(0o022)
begin
  mode = Mode.new(0o700)
  Dir.mkdir("#{base}-a", mode)
  p Dir.exist?("#{base}-a")
  p sprintf("%o", File.stat("#{base}-a").mode & 0o777)
ensure
  Dir.rmdir("#{base}-a") if Dir.exist?("#{base}-a")
  File.umask(mask)
end
