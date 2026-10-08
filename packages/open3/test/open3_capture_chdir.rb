# Open3.capture3, capture2 and capture2e with chdir: run the child in that
# directory, as CRuby passes the option on to Process.spawn. A directory the
# child cannot enter raises Errno::ENOENT.
require "open3"
require "tmpdir"

Dir.mktmpdir("open3_capture_chdir") do |dir|
  real = File.realpath(dir)
  out, err, st = Open3.capture3("pwd", chdir: dir)
  p [out.chomp == real, err, st.success?]
  out, st = Open3.capture2("sh", "-c", "pwd", chdir: dir)
  p [out.chomp == real, st.success?]
  out, st = Open3.capture2e("pwd && echo merged 1>&2", chdir: dir)
  p [out.lines.map(&:chomp) == [real, "merged"], st.success?]
  out, st = Open3.capture2("cat; pwd", stdin_data: "fed in\n", chdir: dir)
  p [out.lines.map(&:chomp) == ["fed in", real], st.success?]
  out, _err, _st = Open3.capture3("pwd")
  p out.chomp == File.realpath(Dir.pwd)

  begin
    Open3.capture3("pwd", chdir: File.join(dir, "missing"))
  rescue SystemCallError => e
    p e.class
  end
end
