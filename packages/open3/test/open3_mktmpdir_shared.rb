# Open3's capture takes a private copy of its temporary directory's path,
# where a program elsewhere changes a String Dir.mktmpdir answered in place:
# Open3's own mktmpdir result was refused at compile time (#9258).
require "open3"
require "tmpdir"

prefix = "spinel_open3_shared_#{Process.pid}_"
p Dir.mktmpdir(prefix).concat("/sub").end_with?("/sub")
Dir.glob(File.join(Dir.tmpdir, "#{prefix}*")).each { |d| Dir.rmdir(d) }

out, err, status = Open3.capture3("echo", "hi")
p out, err, status.success?
out, status = Open3.capture2("sh", "-c", "printf two")
p out, status.exitstatus
