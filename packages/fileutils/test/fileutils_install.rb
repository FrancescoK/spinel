require "fileutils"
require "tmpdir"
require "pathname"

# FileUtils.install: copy unless the contents already match, make the
# destination's directory, set the mode, and take each basename into a
# directory destination. Paths are printed relative to root (it carries a pid).
root = File.join(Dir.tmpdir, "spinel_fu_install_#{Process.pid}")
FileUtils.mkdir_p(File.join(root, "out"))
src = File.join(root, "style.css")
File.write(src, "body {}")
File.chmod(0600, src)

p FileUtils.install(src, File.join(root, "out"), mode: 0644)
dest = File.join(root, "out", "style.css")
p File.read(dest), (File.stat(dest).mode & 0o777).to_s(8)

# the same contents again: no copy, so the old time stays
File.utime(Time.at(1_577_934_240), Time.at(1_577_934_240), dest)
FileUtils.install(src, dest, mode: 0644)
p File.mtime(dest) == Time.at(1_577_934_240)

# new contents: copied over
File.write(src, "body { margin: 0 }")
FileUtils.install(src, dest)
p File.read(dest)

# a missing directory is made; preserve keeps the source's times
File.utime(Time.at(1_577_934_240), Time.at(1_577_934_240), src)
FileUtils.install(src, File.join(root, "deep", "er", "copy.css"), preserve: true)
p File.mtime(File.join(root, "deep", "er", "copy.css")) == File.mtime(src)

# a list goes into the directory, and a Pathname destination is a path
other = File.join(root, "app.js")
File.write(other, "run()")
FileUtils.install([src, other], Pathname.new(File.join(root, "deep")))
p Dir.children(File.join(root, "deep")).sort

# what darkfish does: options gathered in a Hash and splatted
fu_options = { :verbose => nil, :noop => false }
FileUtils.install other, Pathname.new(File.join(root, "out")), **fu_options.merge(:mode => 0640)
p (File.stat(File.join(root, "out", "app.js")).mode & 0o777).to_s(8)

Dir.chdir(root) do
  # a trailing slash names a directory to make
  FileUtils.install("app.js", "made/")
  p File.read("made/app.js")
  FileUtils.install("app.js", "out", mode: 0o644, preserve: true, verbose: true)
  FileUtils.install(["app.js", "style.css"], "elsewhere", verbose: true, noop: true)
  p Dir.exist?("elsewhere")
  begin
    FileUtils.install("app.js", "app.js")
  rescue ArgumentError => e
    puts e.message
  end
  begin
    FileUtils.install("missing.js", "out")
  rescue SystemCallError => e
    p e.class
  end
end
FileUtils.rm_rf(root)
p Dir.exist?(root)
